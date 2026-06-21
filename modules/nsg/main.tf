# -----------------------------------------------------------
# NSG for AKS Subnet
# -----------------------------------------------------------
resource "azurerm_network_security_group" "aks" {
  name                = "nsg-aks-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Rule 1: Allow ALL internal VNet traffic
# Covers: pod-to-pod, DNS (port 53), kubelet (10250), CoreDNS → API server
resource "azurerm_network_security_rule" "allow_vnet_internal" {
  name                        = "allow-vnet-internal"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.aks.name
}

# Rule 2: Allow Azure Load Balancer probes
resource "azurerm_network_security_rule" "allow_azure_lb" {
  name                        = "allow-azure-lb"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "AzureLoadBalancer"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.aks.name
}

# Rule 3: Allow HTTPS inbound (Ingress controller)
resource "azurerm_network_security_rule" "allow_https" {
  name                        = "allow-https-inbound"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.aks.name
}

# Rule 4: Allow HTTP inbound (Ingress controller)
resource "azurerm_network_security_rule" "allow_http" {
  name                        = "allow-http-inbound"
  priority                    = 130
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.aks.name
}

# Rule 5: Allow kubelet port (kubectl logs/exec/attach)
resource "azurerm_network_security_rule" "allow_kubelet" {
  name                        = "allow-kubelet"
  priority                    = 140
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "10250"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.aks.name
}

# Rule 6: Deny Internet inbound (blocks external attackers)
# VirtualNetwork already allowed above so internal traffic is unaffected
resource "azurerm_network_security_rule" "deny_internet_inbound" {
  name                        = "deny-internet-inbound"
  priority                    = 4096
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "Internet"       # ← Internet only, NOT *
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.aks.name
}

# -----------------------------------------------------------
# NSG for App Subnet
# -----------------------------------------------------------
resource "azurerm_network_security_group" "app" {
  name                = "nsg-app-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
  # NO inline security_rule blocks
}

resource "azurerm_network_security_rule" "allow_vnet_inbound_app" {
  name                        = "allow-vnet-inbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.app.name
}

# -----------------------------------------------------------
# Associate NSGs to subnets
# -----------------------------------------------------------
resource "azurerm_subnet_network_security_group_association" "aks" {
  subnet_id                 = var.aks_subnet_id
  network_security_group_id = azurerm_network_security_group.aks.id
}

resource "azurerm_subnet_network_security_group_association" "app" {
  subnet_id                 = var.app_subnet_id
  network_security_group_id = azurerm_network_security_group.app.id
}