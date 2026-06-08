output "aks_nsg_id" {
  value = azurerm_network_security_group.aks.id
}

output "app_nsg_id" {
  value = azurerm_network_security_group.app.id
}
