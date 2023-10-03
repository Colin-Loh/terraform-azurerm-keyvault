# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

<a name="unreleased"></a>
## [Unreleased]

### Feat
- Updated KeyVault Resource specifically network_acls to automatically set Deny when there is a subnet_id to whitelist and Allow when subnet_id is not present
- Updated virtual_network_subnet_rule to check if null, if null then return an empty set of strings
- Made virtual_network variables optional to use
- Updated access_policies variable and users input, seperated to user, groups and application


<a name="v1.1.1"></a>
## [v1.1.1] - 2023-10-02

<a name="v1.1.0"></a>
## [v1.1.0] - 2023-09-25
### Feat
- Updated formatting to match naming convention
- Added a new variable that allow whitelisting of subnet
- Created new function to allow provision of access_policies for Azure KeyVault  dynamically


<a name="v1.0.0"></a>
## v1.0.0 - 2023-09-24

[Unreleased]: https://dev.azure.com/DEV-LOH/DEV-LOH.TerraformResources/_git/terraform-azurerm-virtualnetwork/compare/v1.1.1...HEAD
[v1.1.1]: https://dev.azure.com/DEV-LOH/DEV-LOH.TerraformResources/_git/terraform-azurerm-virtualnetwork/compare/v1.1.0...v1.1.1
[v1.1.0]: https://dev.azure.com/DEV-LOH/DEV-LOH.TerraformResources/_git/terraform-azurerm-virtualnetwork/compare/v1.0.0...v1.1.0

<!-- BEGIN_AUTOMATED_TF_DOCS_BLOCK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | n/a |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_key_vault.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azuread_group.this](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/group) | data source |
| [azuread_service_principal.this](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/service_principal) | data source |
| [azuread_user.this](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/user) | data source |
| [azurerm_client_config.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_private_dns_zone.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/private_dns_zone) | data source |
| [azurerm_subnet.ids](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |
| [azurerm_subnet.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_policy"></a> [access\_policy](#input\_access\_policy) | (Optional) A list of access policies for the key vault. Defaults to an empty list.<br>    Each access policy contains:<br>    - `Name` (Required) - The name of the user, group, or application.<br>    - `key_permissions` (Required) - Permissions to cryptographic keys. For example: ["Get", "List"].<br>    - `secret_permissions` (Required) - Permissions to secrets. For example: ["Get", "List"].<br>    - `certificate_permissions` (Required) - Permissions to certificates. For example: ["Get", "Import", "List"]. | <pre>object({<br>    user = list(object({<br>      Name                    = string<br>      key_permissions         = list(string)<br>      secret_permissions      = list(string)<br>      certificate_permissions = list(string)<br>    })),<br>    group = list(object({<br>      Name                    = string<br>      key_permissions         = list(string)<br>      secret_permissions      = list(string)<br>      certificate_permissions = list(string)<br>    })),<br>    application = list(object({<br>      Name                    = string<br>      key_permissions         = list(string)<br>      secret_permissions      = list(string)<br>      certificate_permissions = list(string)<br>    }))<br>  })</pre> | <pre>{<br>  "application": [],<br>  "group": [],<br>  "user": []<br>}</pre> | no |
| <a name="input_key_vault"></a> [key\_vault](#input\_key\_vault) | (Required) Configuration settings for the Key Vaults.<br>    Properties:<br>    `key_vault` (Required) - Configuration settings for an individual Key Vault. Properties include:<br>      - `name` (Required) - The name of the Key Vault.<br>      - `enabled_for_disk_encryption` (Required) - Specifies whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the key vault.<br>      - `soft_delete_retention_days` (Required) - The number of days that the key vault will retain soft deleted objects.<br>      - `purge_protection_enabled` (Required) - Specifies if protection against purge is enabled for this key vault.<br>      - `sku_name` (Required) - The name of the SKU used to price the Key Vault. Possible values are standard and premium.<br>      - `enabled_for_template_deployment` (Optional) - Specifies whether Azure Resource Manager is permitted to retrieve secrets from the key vault. | <pre>object({<br>    name                            = string<br>    enabled_for_disk_encryption     = bool<br>    enabled_for_template_deployment = bool<br>    soft_delete_retention_days      = number<br>    purge_protection_enabled        = bool<br>    sku_name                        = string<br>  })</pre> | n/a | yes |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | (Required) Resource group details.<br>    Properties:<br>    - `name` (Required) - The name of the resource group.<br>    - `location` (Required) - The location where the resource group should be created. | <pre>object({<br>    name     = string<br>    location = string<br>  })</pre> | n/a | yes |
| <a name="input_virtual_network"></a> [virtual\_network](#input\_virtual\_network) | (Optional) Network settings for the Key Vault to be Private.<br>    Properties:<br>    - `name` (Optional) - The name of the virtual network.<br>    - `dns_zone_name` (Optional) - The DNS zone name associated with the virtual network.<br>    - `resource_group_name` (Optional) - The name of the resource group where the virtual network is located.<br>    - `private_endpoint_subnet_name` (Optional) - The name of the subnet associated with the private endpoint for the Key Vault.<br>    - `dns_zone_name` (Optional) - The private DNS zone name associated with the Key Vault.<br>    - `virtual_network_subnet_rules` (Optional) - A list of subnet should be able to access this KeyVault | <pre>object({<br>    name                         = optional(string, null)<br>    resource_group_name          = optional(string, null)<br>    private_endpoint_subnet_name = optional(string, null)<br>    dns_zone_name                = optional(string, null)<br>    virtual_network_subnet_rules = optional(list(string), [])<br>  })</pre> | n/a | yes |

## Usage
Basic usage of this module is as follows:

```hcl
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
    name                         = each.value.virtual_network.name
    resource_group_name          = each.value.virtual_network.resource_group_name
    private_endpoint_subnet_name = each.value.virtual_network.private_endpoint
    dns_zone_name                = each.value.virtual_network.dns_zone
    virtual_network_subnet_rules = each.value.virtual_network.subnet_rules
  }

  access_policy = each.value.access_policies
}

```
<!-- END_AUTOMATED_TF_DOCS_BLOCK -->