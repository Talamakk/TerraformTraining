terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.59.0"
    }
  }
  required_version = ">= 1.1.0"

}

provider "azurerm" {
  features {}
}

provider "azurerm" {
  alias           = "corp"
  subscription_id = "1832d596-237a-41b8-a464-6f499bd89316"
  features {}
}

provider "azurerm" {
  alias           = "prv"
  subscription_id = "1086b089-6c1b-427a-91b5-dd608433c11a"
  features {}
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "rg_corp" {
  provider = azurerm.corp
  name     = join("-", ["rg-corp", var.region, var.env])
  location = var.region
}

resource "azurerm_resource_group" "rg_prv" {
  provider = azurerm.prv
  name     = join("-", ["rg-prv", var.region, var.env])
  location = var.region
}

resource "azurerm_key_vault" "kv" {
  provider                  = azurerm.prv
  name                      = join("-", ["kv", var.region, var.env])
  location                  = azurerm_resource_group.rg_prv.location
  resource_group_name       = azurerm_resource_group.rg_prv.name
  sku_name                  = "standard"
  tenant_id                 = data.azurerm_client_config.current.tenant_id
  enable_rbac_authorization = true
}

resource "azurerm_key_vault_secret" "vm_password" {
  name         = "vm-password"
  value        = "Pa$$W0rd123"
  key_vault_id = azurerm_key_vault.kv.id
}

resource "azurerm_storage_account" "sa" {
  name                     = join("0", ["sa", var.region, var.env])
  resource_group_name      = azurerm_resource_group.rg_corp.name
  location                 = azurerm_resource_group.rg_corp.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "container" {
  name                  = "scripts"
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "container"
}

resource "azurerm_storage_blob" "script" {
  name                   = "script1.ps1"
  storage_account_name   = azurerm_storage_account.sa.name
  storage_container_name = azurerm_storage_container.container.name
  type                   = "Block"
  source                 = "script.ps1"
}

output "corp_rg_name" {
  description = "Name of resource group in corporate subscription"
  value = azurerm_resource_group.rg_corp.name
}

output "corp_rg_location" {
  description = "Location of resource group in corporate subscription"
  value = azurerm_resource_group.rg_corp.location
}

output "env" {
  description = "Environment where projects is deployed"
  value = var.env
}

output "vm_password" {
  description = "Password to VMs provisioned in corporate subscription"
  value     = azurerm_key_vault_secret.vm_password.value
  sensitive = true
}

output "blob_uri" {
  value = azurerm_storage_blob.script.url
}

