# AKS Cluster
# System-assign managed identity
# Azure CNI for VNet integration
# Cluster Autoscaler enabled
# RBAC + Azure AD integration
# Workload Identity Enabled

resource "azurerm_kubernetes_cluster" "this" {
    name = var.cluster_name
    location = var.location
    resource_group_name = var.resource_group_name
    dns_prefix = var.dns_prefix
    kubernetes_version = var.kubernetes_version

    identity {
        type = "SystemAssigned"
    }

    # Default Node Pool

    default_node_pool {
        name = "system"
        node_count = var.node_count
        vm_size = var.node_size
        vnet_subnet_id = var.vnet_subnet_id
        os_disk_size_gb = 50
        type = "VirtualMachineScaleSets"

        enable_auto_scaling = true
        min_count = var.min_count
        max_count = var.max_count

        only_critical_addons_enabled = true

        node_labels = {
            "nodepool-type" = "system"
            "environment" = var.tags["environment"]
        }
    }

    network_profile {
        network_plugin = "azure"
        network_policy = "azure"
        load_balancer_sku = "standard"
        outbound_type = "loadBalancer"
        service_cidr       = "10.254.0.0/16" 
        dns_service_ip     = "10.254.0.10"  
    }

    # Azure monitor

    oms_agent {
        log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
    }

    # Azure Key Vault Secrets Provider - mounts secrets as volumes

    key_vault_secrets_provider {
        secret_rotation_enabled = true
        secret_rotation_interval = "2m"
    }

    # Allowing pods to authenticate to Azure services without secrets

    workload_identity_enabled = true
    oidc_issuer_enabled = true

    # RBAC + Azure AD integration

    role_based_access_control_enabled = true

    # Maintenance Window

    maintenance_window {
        allowed {
        day = "Saturday"
        hours = [2, 3]
        }
    }

    tags = var.tags
    

    lifecycle {
        ignore_changes = [ 
            default_node_pool[0].node_count,
            kubernetes_version,
        ]
    }

}

# User Node Pool (for application workloads)
# Separated from system pool — enterprise best practice

resource "azurerm_kubernetes_cluster_node_pool" "app" {
    name                  = "app"
    kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
    vm_size               = var.node_size
    vnet_subnet_id        = var.vnet_subnet_id
    os_disk_size_gb       = 50
    mode                  = "User"

    enable_auto_scaling = true
    min_count           = var.min_count
    max_count           = var.max_count
    node_count          = var.node_count

    node_labels = {
        "nodepool-type" = "app"
        "environment"   = var.tags["environment"]
    }
    tags = var.tags
}


# Log Analytics Workspace for Azure Monitor
resource "azurerm_log_analytics_workspace" "this" {
    name                = "law-${var.cluster_name}"
    location            = var.location
    resource_group_name = var.resource_group_name
    sku                 = "PerGB2018"
    retention_in_days   = 30 # minimum — reducing cost in dev
    tags                = var.tags
}


# Role Assignment for AKS Identity - Pull from ACR
# Allows AKS to pull images without imagePullSecrets

resource "azurerm_role_assignment" "aks_acr_pull" {
    count = var.acr_id != null && var.acr_id != "" ? 1 : 0    
    scope = var.acr_id
    role_definition_name = "AcrPull"
    principal_id         = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}
