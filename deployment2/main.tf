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

data "terraform_remote_state" "deployment1" {
  backend = "local"
  config = {
    path = "../deployment1/terraform.tfstate"
  }
}

locals {
  region      = data.terraform_remote_state.deployment1.outputs.corp_rg_location
  rg_name     = data.terraform_remote_state.deployment1.outputs.corp_rg_name
  env         = data.terraform_remote_state.deployment1.outputs.env
  vm_password = data.terraform_remote_state.deployment1.outputs.vm_password
  blob_uri = data.terraform_remote_state.deployment1.outputs.blob_uri
}

module "compute" {
  source = "./compute"

  instances   = var.instances
  region      = local.region
  env         = local.env
  rg_name     = local.rg_name
  subnet_id   = azurerm_subnet.subnet.id
  vm_password = local.vm_password
  blob_uri = local.blob_uri
}

