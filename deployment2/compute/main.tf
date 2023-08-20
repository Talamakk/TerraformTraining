resource "azurerm_network_interface" "nic" {
  count = var.instances

  name                = join("-", ["nic", var.region, var.env, "${format("%03s", count.index + 1)}"])
  location            = var.region
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip[count.index].id
  }
}

resource "azurerm_public_ip" "public_ip" {
  count = var.instances

  name                = join("-", ["pip", var.region, var.env, "${format("%03s", count.index + 1)}"])
  resource_group_name = var.rg_name
  location            = var.region
  allocation_method   = "Dynamic"
}

resource "azurerm_windows_virtual_machine" "vm" {
  count = var.instances

  name                = join("-", ["vm", var.region, var.env, "${format("%03s", count.index + 1)}"])
  resource_group_name = var.rg_name
  location            = var.region
  size                = "Standard_B2s"
  admin_username      = "adminuser"
  admin_password      = var.vm_password
  computer_name       = "WinServerVm"
  network_interface_ids = [
    azurerm_network_interface.nic[count.index].id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_virtual_machine_extension" "script" {
  count = var.instances

  name                 = "new_file_script"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm[count.index].id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

settings             = <<SETTINGS
      {
          "fileUris": ["${var.blob_uri}"],
          "commandToExecute": "powershell -ExecutionPolicy Unrestricted -file script1.ps1"
      }
  SETTINGS

}

resource "azurerm_recovery_services_vault" "rsv" {
  name                = join("-", ["rsv", var.region, var.env])
  location            = var.region
  resource_group_name = var.rg_name
  storage_mode_type   = "LocallyRedundant"
  sku                 = "Standard"

  soft_delete_enabled = false

  depends_on = [azurerm_windows_virtual_machine.vm]
}

resource "azurerm_backup_policy_vm" "rsv_policy" {
  name                = "rsv_policy"
  resource_group_name = var.rg_name
  recovery_vault_name = azurerm_recovery_services_vault.rsv.name

  timezone = "UTC"

  backup {
    frequency = "Daily"
    time      = "02:00"
  }

  retention_daily {
    count = 7
  }
}

resource "azurerm_backup_protected_vm" "vms_backup" {
  count = var.instances

  resource_group_name = var.rg_name
  recovery_vault_name = azurerm_recovery_services_vault.rsv.name
  source_vm_id        = azurerm_windows_virtual_machine.vm[count.index].id
  backup_policy_id    = azurerm_backup_policy_vm.rsv_policy.id
}