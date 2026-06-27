data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "this" {
    name                          = var.name
    location                      = var.location
    resource_group_name           = var.resource_group_name
    tenant_id                     = data.azurerm_client_config.current.tenant_id
    sku_name                      = "standard"
    enable_rbac_authorization     = true
    purge_protection_enabled      = false
    soft_delete_retention_days    = 7

    network_acls {
        default_action = "Allow"
        bypass = "AzureServices"
    }
        
    tags = var.tags
}


resource "azurerm_role_assignment" "aks_kv_secrets_user" {
    scope                = azurerm_key_vault.this.id
    role_definition_name = "Key Vault Secrets User"
    principal_id         = var.kubelet_identity_object_id
}

resource "azurerm_role_assignment" "admin_kv_officer" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}