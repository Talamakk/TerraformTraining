resource "azurerm_virtual_network" "vnet" {
  provider            = azurerm.corp
  name                = join("-", ["vnet", local.region, local.env])
  location            = local.region
  resource_group_name = local.rg_name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = join("-", ["subnet", local.region, local.env])
  resource_group_name  = local.rg_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}