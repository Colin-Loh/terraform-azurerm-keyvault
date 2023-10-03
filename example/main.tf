provider "azurerm" {
  features {}
}

locals {
  raw_config = yamldecode(file("./config.yaml"))
}

resource "azurerm_resource_group" "this" {
  name     = local.raw_config.resource_group.name
  location = local.raw_config.resource_group.location
}

data "azurerm_client_config" "current" {}

module "key_vault" {
  source = "../"

  for_each = local.raw_config.key_vaults

  key_vault = each.value.key_vault

  resource_group = {
    name     = azurerm_resource_group.this.name
    location = azurerm_resource_group.this.location
  }

  virtual_network = {
    name                         = can(each.value.virtual_network.name) ? each.value.virtual_network.name : ""
    resource_group_name          = can(each.value.virtual_network.resource_group_name) ? each.value.virtual_network.resource_group_name : ""
    private_endpoint_subnet_name = can(each.value.virtual_network.private_endpoint) ? each.value.virtual_network.private_endpoint : ""
    dns_zone_name                = can(each.value.virtual_network.dns_zone) ? each.value.virtual_network.dns_zone : ""
    virtual_network_subnet_rules = can(each.value.virtual_network.subnet_rules) ? each.value.virtual_network.subnet_rules : []
  }

  access_policy = each.value.access_policies
}
