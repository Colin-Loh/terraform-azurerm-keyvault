data "azurerm_client_config" "this" {}

data "azuread_user" "this" {
  for_each = {
    for user in var.access_policy.user :
    user.Name => user
  }

  user_principal_name = each.key
}

data "azuread_group" "this" {
  for_each = {
    for group in var.access_policy.group :
    group.Name => group
  }

  display_name = each.key
}

data "azuread_service_principal" "this" {
  for_each = {
    for application in var.access_policy.application :
    application.Name => application
  }

  display_name = each.key
}


locals {
  #Retrieve the object ids of the users, groups and applications
  group_object_ids = {
    for g in data.azuread_group.this :
    lower(g.display_name) => g.id
  }
  user_object_ids = {
    for u in data.azuread_user.this :
    lower(u.user_principal_name) => u.id
  }
  app_object_ids = {
    for s in data.azuread_service_principal.this :
    lower(s.display_name) => s.id
  }

  #Retrrieve the names of the users, groups and applications
  group_names = distinct([
    for group in flatten(var.access_policy[*].group) :
    group.Name
  ])
  user_names = distinct([
    for user in flatten(var.access_policy[*].user) :
    user.Name
  ])
  appliaction_names = distinct([
    for app in flatten(var.access_policy[*].application) :
    app.Name
  ])

  #This creates a new list of objects with the object_id of the user, group or application
  flattened_access_policies = {
    for i in flatten([
      for type, policies in var.access_policy : [
        for policy in policies : {
          id = policy.Name
          data = {
            name                    = policy.Name
            key_permissions         = policy.key_permissions
            secret_permissions      = policy.secret_permissions
            certificate_permissions = policy.certificate_permissions
            object_id = (
              contains(local.group_names, policy.Name) ? local.group_object_ids[lower(policy.Name)] :
              contains(local.user_names, policy.Name) ? local.user_object_ids[lower(policy.Name)] :
              contains(local.appliaction_names, policy.Name) ? local.app_object_ids[lower(policy.Name)] :
              null
            )
          }
        }
      ]
    ]) : i.id => i.data
  }
}

#Optional subnet that will be allowed to access the KeyVault
data "azurerm_subnet" "ids" {
  for_each = can(var.virtual_network.virtual_network_subnet_rules) ? toset(var.virtual_network.virtual_network_subnet_rules) : toset([])

  name                 = each.key
  virtual_network_name = var.virtual_network.name
  resource_group_name  = var.virtual_network.resource_group_name
}

resource "azurerm_key_vault" "this" {
  name                            = var.key_vault.name
  resource_group_name             = var.resource_group.name
  location                        = var.resource_group.location
  enabled_for_disk_encryption     = var.key_vault.enabled_for_disk_encryption
  enabled_for_template_deployment = var.key_vault.enabled_for_template_deployment
  enable_rbac_authorization       = false
  tenant_id                       = data.azurerm_client_config.this.tenant_id
  soft_delete_retention_days      = var.key_vault.soft_delete_retention_days
  purge_protection_enabled        = var.key_vault.purge_protection_enabled
  sku_name                        = var.key_vault.sku_name

  network_acls {
    bypass         = "AzureServices"
    default_action = length(var.virtual_network.virtual_network_subnet_rules) > 0 ? "Deny" : "Allow"
    virtual_network_subnet_ids = [
      for subnet in data.azurerm_subnet.ids :
      subnet.id
    ] 
  }

  #ISSUE: Unable to delete access_policy block if condition is false
  dynamic "access_policy" {
    for_each = length(local.flattened_access_policies) > 0 ? local.flattened_access_policies : {} #This should remove the dynamic block if the condition is false, in this case, even if the dynamic block is removed. The resource will still remain
    # for_each = length(local.flattened_access_policies) > 0 ? local.flattened_access_policies : { "dummy" = { object_id = null, key_permissions = [], secret_permissions = [], certificate_permissions = [] } }

    content {
      tenant_id               = data.azurerm_client_config.this.tenant_id
      object_id               = access_policy.value.object_id
      key_permissions         = access_policy.value.key_permissions
      secret_permissions      = access_policy.value.secret_permissions
      certificate_permissions = access_policy.value.certificate_permissions
    }
  }
}

data "azurerm_subnet" "this" {
  for_each = var.virtual_network.private_endpoint_subnet_name != "" ? { enabled = true } : {}

  name                 = var.virtual_network.private_endpoint_subnet_name
  virtual_network_name = var.virtual_network.name
  resource_group_name  = var.virtual_network.resource_group_name
}

data "azurerm_private_dns_zone" "this" {
  for_each = var.virtual_network.dns_zone_name != "" ? { enabled = true } : {}

  name                = var.virtual_network.dns_zone_name
  resource_group_name = var.virtual_network.resource_group_name
}

resource "azurerm_private_endpoint" "this" {
  for_each = var.virtual_network.private_endpoint_subnet_name != "" ? { enabled = true } : {}

  name                          = format("%s-%s", azurerm_key_vault.this.name, "pe")
  resource_group_name           = var.resource_group.name
  location                      = var.resource_group.location
  subnet_id                     = data.azurerm_subnet.this[each.key].id #The subnet that the private endpoint will be created. 
  custom_network_interface_name = format("%s-%s", replace(azurerm_key_vault.this.name, "-", ""), "nic")

  private_dns_zone_group {
    name                 = format("%s-%s", azurerm_key_vault.this.name, "privatednszonegroup")
    private_dns_zone_ids = [data.azurerm_private_dns_zone.this[each.key].id]
  }

  private_service_connection {
    name                           = format("%s-%s", azurerm_key_vault.this.name, "pse")
    private_connection_resource_id = azurerm_key_vault.this.id
    is_manual_connection           = false
    subresource_names              = ["Vault"]
  }
}