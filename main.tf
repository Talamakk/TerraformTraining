terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.59.0"
    }
  }
  required_version = ">= 1.1.0"

  cloud {
    organization = "TestOrg_13"

    workspaces {
      name = "workspace1"
    }
  }
}

provider "azurerm" {
  # Configuration options
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = join("-", ["rg", var.region, var.env])
  location = var.region
}

module "compute" {
  source = "./compute"

  instances = var.instances
  region    = var.region
  env       = var.env
  rg_name   = azurerm_resource_group.rg.name
  subnet_id = azurerm_subnet.subnet.id
}
