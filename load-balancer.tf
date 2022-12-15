resource "azurerm_public_ip" "lb1_pip" {
  name                = "lb1_pip"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "lb1" {
  name                = "lb1"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name
  frontend_ip_configuration {
    name                          = "default"
    public_ip_address_id          = azurerm_public_ip.lb1_pip.id
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_lb_backend_address_pool" "lb1_bap" {
  name            = "lb1_bap"
  loadbalancer_id = azurerm_lb.lb1.id
}

resource "azurerm_network_interface_backend_address_pool_association" "lb1_bap_association" {
  count                   = var.arm_vm_count
  network_interface_id    = "${element(azurerm_network_interface.nic.*.id, count.index)}"
  ip_configuration_name   = "${element(azurerm_network_interface.nic.*.ip_configuration.0.name, count.index)}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb1_bap.id
}

resource "azurerm_lb_probe" "lb1_probe_80" {
  name            = "lb1_probe_80"
  loadbalancer_id = azurerm_lb.lb1.id
  protocol        = "Tcp"
  request_path    = "/"
  port            = 80
}

resource "azurerm_lb_rule" "lb1_rule_80" {
  name                           = "lb1_rule_80"
  loadbalancer_id                = azurerm_lb.lb1.id
  backend_address_pool_ids       = ["${azurerm_lb_backend_address_pool.lb1_bap.id}"]
  probe_id                       = azurerm_lb_probe.lb1_probe_80.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "default"
}

resource "azurerm_lb_probe" "lb1_probe_443" {
  name            = "lb1_probe_443"
  loadbalancer_id = azurerm_lb.lb1.id
  protocol        = "Tcp"
  request_path    = "/"
  port            = 443
}

resource "azurerm_lb_rule" "lb1_rule_443" {
  name                           = "lb1_rule_443"
  loadbalancer_id                = azurerm_lb.lb1.id
  backend_address_pool_ids       = ["${azurerm_lb_backend_address_pool.lb1_bap.id}"]
  probe_id                       = azurerm_lb_probe.lb1_probe_443.id
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "default"
}