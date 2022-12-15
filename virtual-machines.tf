resource "azurerm_availability_set" "as1" {
  name                         = "as1"
  location                     = azurerm_resource_group.rg1.location
  resource_group_name          = azurerm_resource_group.rg1.name
  platform_fault_domain_count  = 3
  platform_update_domain_count = 20
  managed                      = true
}

resource "azurerm_storage_container" "storage_container" {
  count                 = var.arm_vm_count
  name                  = "storage-container-${count.index}"
  storage_account_name  = azurerm_storage_account.sa1.name
  container_access_type = "private"
}

resource "azurerm_network_interface" "nic" {
  count               = var.arm_vm_count
  name                = "nic-${count.index}"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name

  ip_configuration {
    name                          = "ip_config-${count.index}"
    subnet_id                     = azurerm_subnet.subnet_frontend.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "vm" {
  count                 = var.arm_vm_count
  name                  = "vm-${count.index}"
  location              = azurerm_resource_group.rg1.location
  resource_group_name   = azurerm_resource_group.rg1.name
  network_interface_ids = ["${element(azurerm_network_interface.nic.*.id, count.index)}"]
  vm_size               = "Standard_B1s"
  availability_set_id   = azurerm_availability_set.as1.id

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "osdisk-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  # Optional data disks
  storage_data_disk {
    name              = "datadisk-${count.index}"
    managed_disk_type = "Standard_LRS"
    disk_size_gb      = "1023"
    create_option     = "Empty"
    lun               = 0
  }

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  os_profile {
    computer_name  = "vm-${count.index}"
    admin_username = "clouduser"
    admin_password = var.arm_vm_admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}
