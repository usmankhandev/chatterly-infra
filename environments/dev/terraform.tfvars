subscription_id = "1f69f3b3-56e3-4f4e-aec6-6e4f06d45e9e"

environment = "dev"
location = "eastus"
project = "chatterly"

# Networking
vnet_address_space = ["10.0.0.0/16"]
aks_subnet_cidr    = "10.0.1.0/24"
app_subnet_cidr    = "10.0.2.0/24"

# AKS — cost-optimized for dev (free trial)
kubernetes_version = "1.33.12"
aks_node_count     = 1
aks_node_size      = "Standard_D2s_v3"
aks_min_count      = 1
aks_max_count      = 2 

tags = {
  owner      = "osman"
  cost-center = "learning"
  repo       = "chatterly-infra"
}
