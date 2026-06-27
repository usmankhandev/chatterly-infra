locals {
    name_prefix = "${var.project}-${var.environment}"
    common_tags = merge(var.tags, {
        project = var.project
        environment = var.environment
        managed_by = "terraform"
        team = "platform"
    })
}

variable "admin_enabled" {
    description = "Enable admin user for ACR"
    type        = bool
    default     = false
}

# Module: Resource Group

module "resource_group" {
    source = "./modules/resource-group"
    name = "rg-${local.name_prefix}"
    location = var.location
    tags = local.common_tags
}

# VNET 

module "vnet" {
    source = "./modules/vnet"
    name = "vnet-${local.name_prefix}"
    location = var.location
    resource_group_name = module.resource_group.name
    address_space = var.vnet_address_space
    aks_subnet_cidr = var.aks_subnet_cidr
    app_subnet_cidr = var.app_subnet_cidr
    tags = local.common_tags
}


# NSG 

module "nsg" {
    source = "./modules/nsg"

    resource_group_name = module.resource_group.name
    location = var.location
    environment = var.environment
    name_prefix = local.name_prefix
    aks_subnet_id = module.vnet.aks_subnet_id
    app_subnet_id = module.vnet.app_subnet_id
    tags = local.common_tags
}


# AKS

module "aks" {
  source = "./modules/aks"

  cluster_name        = "aks-${local.name_prefix}"
  resource_group_name = module.resource_group.name
  location            = var.location
  kubernetes_version  = var.kubernetes_version
  dns_prefix          = "${local.name_prefix}-k8s"

  # Node pool configuration.
  node_count = var.aks_node_count
  node_size  = var.aks_node_size
  min_count  = var.aks_min_count
  max_count  = var.aks_max_count

  # Networking
  vnet_subnet_id = module.vnet.aks_subnet_id

  tags = local.common_tags

  depends_on = [module.nsg]
}

# ACR

module "acr" {
    source = "./modules/acr"

    name = "acrchatterlydev"
    resource_group_name = module.resource_group.name
    location = var.location
    sku = "Basic"
    admin_enabled = var.admin_enabled
    tags = local.common_tags
}


module "keyvault" {
    source              = "./modules/keyvault"
    name                = "kv-chatterly-dev"    
    location            = var.location
    resource_group_name = module.resource_group.name
    kubelet_identity_object_id = module.aks.kubelet_identity_object_id
    tags                = local.common_tags
}