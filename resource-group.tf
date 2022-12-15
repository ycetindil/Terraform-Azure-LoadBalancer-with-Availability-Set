resource "azurerm_resource_group" "rg1" {
  name     = var.arm_resource_group
  location = var.arm_location
}