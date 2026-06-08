resource "azurerm_virtual_network" "this" {
    name                = var.name
    location            = var.location
    resource_group_name = var.resource_group_name
    address_space       = var.address_space
    tags                = var.tags
}

# subnets - aks subnet (dedicated for node pools) and app subnet (for any non-AKS workloads)

resource "azurerm_subnet" "aks" {
    name = "snet-aks"
    resource_group_name = var.resource_group_name
    virtual_network_name = azurerm_virtual_network.this.name
    address_prefixes = [var.aks_subnet_cidr]

    # Required for AKS CNI networking
    service_endpoints = ["Microsoft.ContainerRegistry"]
}

resource "azurerm_subnet" "app" {
    name = "snet-app"
    resource_group_name = var.resource_group_name
    virtual_network_name = azurerm_virtual_network.this.name
    address_prefixes = [var.app_subnet_cidr]
    service_endpoints = ["Microsoft.KeyVault", "Microsoft.Sql"]
}   

