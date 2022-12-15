output "subnet_frontend_id" {
  value = azurerm_subnet.subnet_frontend.id
}

output "subnet_backend_id" {
  value = azurerm_subnet.subnet_backend.id
}

output "lb1_pip" {
  value = azurerm_public_ip.lb1_pip.ip_address
}