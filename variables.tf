variable "access_policy" {
  type = object({
    user = list(object({
      Name                    = string
      key_permissions         = list(string)
      secret_permissions      = list(string)
      certificate_permissions = list(string)
    })),
    group = list(object({
      Name                    = string
      key_permissions         = list(string)
      secret_permissions      = list(string)
      certificate_permissions = list(string)
    })),
    application = list(object({
      Name                    = string
      key_permissions         = list(string)
      secret_permissions      = list(string)
      certificate_permissions = list(string)
    }))
  })
  description = <<DESC
    (Optional) A list of access policies for the key vault. Defaults to an empty list.
    Each access policy contains:
    - `Name` (Required) - The name of the user, group, or application.
    - `key_permissions` (Required) - Permissions to cryptographic keys. For example: ["Get", "List"].
    - `secret_permissions` (Required) - Permissions to secrets. For example: ["Get", "List"].
    - `certificate_permissions` (Required) - Permissions to certificates. For example: ["Get", "Import", "List"].
  DESC
  default = {
    user        = [],
    group       = [],
    application = []
  }
}

variable "key_vault" {
  type = object({
    name                            = string
    enabled_for_disk_encryption     = bool
    enabled_for_template_deployment = bool
    soft_delete_retention_days      = number
    purge_protection_enabled        = bool
    sku_name                        = string
  })
  description = <<DESC
    (Required) Configuration settings for the Key Vaults.
    Properties:
    `key_vault` (Required) - Configuration settings for an individual Key Vault. Properties include:
      - `name` (Required) - The name of the Key Vault.
      - `enabled_for_disk_encryption` (Required) - Specifies whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the key vault.
      - `soft_delete_retention_days` (Required) - The number of days that the key vault will retain soft deleted objects.
      - `purge_protection_enabled` (Required) - Specifies if protection against purge is enabled for this key vault.
      - `sku_name` (Required) - The name of the SKU used to price the Key Vault. Possible values are standard and premium.
      - `enabled_for_template_deployment` (Optional) - Specifies whether Azure Resource Manager is permitted to retrieve secrets from the key vault.
  DESC

  validation {
    condition = contains(
      ["premium", "standard"],
      var.key_vault.sku_name
    )
    error_message = "Err: invalid sku name, should either be premium or standard."
  }
}

variable "resource_group" {
  type = object({
    name     = string
    location = string
  })
  description = <<DESC
    (Required) Resource group details.
    Properties:
    - `name` (Required) - The name of the resource group.
    - `location` (Required) - The location where the resource group should be created.
  DESC
}

variable "virtual_network" {
  type = object({
    name                         = optional(string, null)
    resource_group_name          = optional(string, null)
    private_endpoint_subnet_name = optional(string, null)
    dns_zone_name                = optional(string, null)
    virtual_network_subnet_rules = optional(list(string), [])
  })
  description = <<DESC
    (Optional) Network settings for the Key Vault to be Private.
    Properties:
    - `name` (Optional) - The name of the virtual network.
    - `dns_zone_name` (Optional) - The DNS zone name associated with the virtual network.
    - `resource_group_name` (Optional) - The name of the resource group where the virtual network is located.
    - `private_endpoint_subnet_name` (Optional) - The name of the subnet associated with the private endpoint for the Key Vault.
    - `dns_zone_name` (Optional) - The private DNS zone name associated with the Key Vault.
    - `virtual_network_subnet_rules` (Optional) - A list of subnet should be able to access this KeyVault
  DESC
  default     = {}
}
