# Public vault example

 This module provisions a private Key Vault instance by creating a Private Endpoint in the provided subnet. It also enables
 RBAC authorization for the Key Vault.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.77 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.117.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_resource_names"></a> [resource\_names](#module\_resource\_names) | terraform.registry.launch.nttdata.com/module_library/resource_name/launch | ~> 1.0 |
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | terraform.registry.launch.nttdata.com/module_primitive/resource_group/azurerm | ~> 1.0 |
| <a name="module_network"></a> [network](#module\_network) | terraform.registry.launch.nttdata.com/module_primitive/virtual_network/azurerm | ~> 2.0 |
| <a name="module_private_dns_zone"></a> [private\_dns\_zone](#module\_private\_dns\_zone) | terraform.registry.launch.nttdata.com/module_primitive/private_dns_zone/azurerm | ~> 1.0 |
| <a name="module_key_vault"></a> [key\_vault](#module\_key\_vault) | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | Location of the resource group and other services in this module. | `string` | n/a | yes |
| <a name="input_enabled_for_deployment"></a> [enabled\_for\_deployment](#input\_enabled\_for\_deployment) | If Azure VM is permitted to retrieve secrets | `bool` | `false` | no |
| <a name="input_enabled_for_template_deployment"></a> [enabled\_for\_template\_deployment](#input\_enabled\_for\_template\_deployment) | If Azure RM is permitted to retrieve secrets | `bool` | `false` | no |
| <a name="input_soft_delete_retention_days"></a> [soft\_delete\_retention\_days](#input\_soft\_delete\_retention\_days) | Number of retention days for soft delete | `number` | `7` | no |
| <a name="input_purge_protection_enabled"></a> [purge\_protection\_enabled](#input\_purge\_protection\_enabled) | If purge\_protection is enabled | `bool` | `false` | no |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | SKU for the key vault - standard or premium | `string` | `"standard"` | no |
| <a name="input_access_policies"></a> [access\_policies](#input\_access\_policies) | Additional Access policies for the vault except the current user which are added by default | <pre>map(object({<br>    object_id               = string<br>    tenant_id               = string<br>    key_permissions         = list(string)<br>    certificate_permissions = list(string)<br>    secret_permissions      = list(string)<br>    storage_permissions     = list(string)<br>  }))</pre> | `{}` | no |
| <a name="input_enable_rbac_authorization"></a> [enable\_rbac\_authorization](#input\_enable\_rbac\_authorization) | Enable RBAC authorization for the key vault | `bool` | `false` | no |
| <a name="input_network_acls"></a> [network\_acls](#input\_network\_acls) | Network ACLs for the key vault | <pre>object({<br>    bypass                     = string<br>    default_action             = string<br>    ip_rules                   = optional(list(string))<br>    virtual_network_subnet_ids = optional(list(string))<br>  })</pre> | <pre>{<br>  "bypass": "AzureServices",<br>  "default_action": "Allow",<br>  "ip_rules": [],<br>  "virtual_network_subnet_ids": []<br>}</pre> | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | (Optional) Whether public network access is allowed for this Key Vault. Defaults to true. | `bool` | `true` | no |
| <a name="input_certificates"></a> [certificates](#input\_certificates) | List of certificates to be imported. If `filepath` is specified then the pfx files should be present in the root of the module (path.root). If `content` is specified then the content of the certificate should be provided in base 64 encoded format. Only one of them should be provided. | <pre>map(object({<br>    contents = optional(string)<br>    filepath = optional(string)<br>    password = string<br>  }))</pre> | `{}` | no |
| <a name="input_certificate_issuers"></a> [certificate\_issuers](#input\_certificate\_issuers) | List of certificate issuers to be created | <pre>map(object({<br>    provider_name = string<br>    org_id        = string<br>    account_id    = string<br>    password      = string<br><br>    admins = optional(list(object({<br>      email_address = string<br>      first_name    = optional(string)<br>      last_name     = optional(string)<br>      phone         = optional(string)<br>    })))<br>  }))</pre> | `{}` | no |
| <a name="input_generated_certificates"></a> [generated\_certificates](#input\_generated\_certificates) | List of certificates to be generated using an issuer. | <pre>map(object({<br>    issuer_name = string<br><br>    key_properties = optional(object({<br>      exportable = bool<br>      reuse_key  = bool<br>      key_type   = string<br><br>      key_size = optional(number, 2048)<br>      curve    = optional(string, "P-256")<br>    }))<br><br>    lifetime_action = optional(object({<br>      action = object({<br>        action_type = string<br>      })<br>      trigger = object({<br>        lifetime_percentage = optional(number)<br>        days_before_expiry  = optional(number)<br>      })<br>    }))<br><br>    secret_properties = optional(object({<br>      content_type = string<br>    }))<br><br>    x509_certificate_properties = optional(object({<br>      key_usage          = list(string)<br>      extended_key_usage = optional(list(string))<br>      subject            = string<br>      validity_in_months = number<br>      subject_alternative_names = optional(object({<br>        dns_names = optional(list(string))<br>        emails    = optional(list(string))<br>        upns      = optional(list(string))<br>      }))<br>    }))<br>  }))</pre> | `{}` | no |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | List of secrets (name and value) | `map(string)` | `{}` | no |
| <a name="input_resource_names_map"></a> [resource\_names\_map](#input\_resource\_names\_map) | A map of key to resource\_name that will be used by tf-launch-module\_library-resource\_name to generate resource names | <pre>map(object({<br>    name       = string<br>    max_length = optional(number, 60)<br>  }))</pre> | <pre>{<br>  "key_vault": {<br>    "max_length": 24,<br>    "name": "kv"<br>  },<br>  "private_dns_zone_link": {<br>    "max_length": 80,<br>    "name": "pdzl"<br>  },<br>  "private_endpoint": {<br>    "max_length": 80,<br>    "name": "pe"<br>  },<br>  "private_service_connection": {<br>    "max_length": 80,<br>    "name": "pesc"<br>  },<br>  "resource_group": {<br>    "max_length": 80,<br>    "name": "rg"<br>  },<br>  "resource_group_vnet": {<br>    "max_length": 80,<br>    "name": "vnetrg"<br>  },<br>  "vnet": {<br>    "max_length": 60,<br>    "name": "vnet"<br>  }<br>}</pre> | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment in which the resource should be provisioned like dev, qa, prod etc. | `string` | n/a | yes |
| <a name="input_environment_number"></a> [environment\_number](#input\_environment\_number) | The environment count for the respective environment. Defaults to 000. Increments in value of 1 | `string` | `"000"` | no |
| <a name="input_resource_number"></a> [resource\_number](#input\_resource\_number) | The resource count for the respective resource. Defaults to 000. Increments in value of 1 | `string` | `"000"` | no |
| <a name="input_logical_product_family"></a> [logical\_product\_family](#input\_logical\_product\_family) | (Required) Name of the product family for which the resource is created.<br>    Example: org\_name, department\_name. | `string` | n/a | yes |
| <a name="input_logical_product_service"></a> [logical\_product\_service](#input\_logical\_product\_service) | (Required) Name of the product service for which the resource is created.<br>    For example, backend, frontend, middleware etc. | `string` | n/a | yes |
| <a name="input_use_azure_region_abbr"></a> [use\_azure\_region\_abbr](#input\_use\_azure\_region\_abbr) | Use Azure region abbreviation in the resource name | `bool` | `true` | no |
| <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments) | A map of role assignments to be created | <pre>map(object({<br>    role_definition_name = string<br>    principal_id         = string<br>    principal_type       = string<br>  }))</pre> | `{}` | no |
| <a name="input_role_assignment_type"></a> [role\_assignment\_type](#input\_role\_assignment\_type) | The type of role assignment to be created | `string` | `"ServicePrincipal"` | no |
| <a name="input_zone_name"></a> [zone\_name](#input\_zone\_name) | Name of the private dns zone. For public cloud, the default value is `privatelink.vaultcore.azure.net` and for sovereign clouds, the default value is `privatelink.vaultcore.usgovcloudapi.net` | `string` | `"privatelink.vaultcore.azure.net"` | no |
| <a name="input_private_dns_zone_group_name"></a> [private\_dns\_zone\_group\_name](#input\_private\_dns\_zone\_group\_name) | Specifies the Name of the Private DNS Zone Group. | `string` | `""` | no |
| <a name="input_is_manual_connection"></a> [is\_manual\_connection](#input\_is\_manual\_connection) | Does the Private Endpoint require Manual Approval from the remote resource owner? Changing this forces a new resource<br>    to be created. | `bool` | `false` | no |
| <a name="input_subresource_names"></a> [subresource\_names](#input\_subresource\_names) | A list of subresource names which the Private Endpoint is able to connect to. subresource\_names corresponds to group\_id.<br>    Possible values are detailed in the product documentation in the Subresources column.<br>    https://docs.microsoft.com/azure/private-link/private-endpoint-overview#private-link-resource | `list(string)` | <pre>[<br>  "vault"<br>]</pre> | no |
| <a name="input_request_message"></a> [request\_message](#input\_request\_message) | A message passed to the owner of the remote resource when the private endpoint attempts to establish the connection<br>    to the remote resource. The request message can be a maximum of 140 characters in length.<br>    Only valid if `is_manual_connection=true` | `string` | `""` | no |
| <a name="input_use_for_each"></a> [use\_for\_each](#input\_use\_for\_each) | Use `for_each` instead of `count` to create multiple resource instances. | `bool` | n/a | yes |
| <a name="input_address_space"></a> [address\_space](#input\_address\_space) | The address space that is used by the virtual network. | `list(string)` | n/a | yes |
| <a name="input_bgp_community"></a> [bgp\_community](#input\_bgp\_community) | (Optional) The BGP community attribute in format `<as-number>:<community-value>`. | `string` | `null` | no |
| <a name="input_ddos_protection_plan"></a> [ddos\_protection\_plan](#input\_ddos\_protection\_plan) | The set of DDoS protection plan configuration | <pre>object({<br>    enable = bool<br>    id     = string<br>  })</pre> | `null` | no |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | The DNS servers to be used with vNet. | `list(string)` | `[]` | no |
| <a name="input_nsg_ids"></a> [nsg\_ids](#input\_nsg\_ids) | A map of subnet name to Network Security Group IDs | `map(string)` | `{}` | no |
| <a name="input_route_tables_ids"></a> [route\_tables\_ids](#input\_route\_tables\_ids) | A map of subnet name to Route table ids | `map(string)` | `{}` | no |
| <a name="input_subnet_delegation"></a> [subnet\_delegation](#input\_subnet\_delegation) | A map of subnet name to delegation block on the subnet | `map(map(any))` | `{}` | no |
| <a name="input_subnet_private_endpoint_network_policies_enabled"></a> [subnet\_private\_endpoint\_network\_policies\_enabled](#input\_subnet\_private\_endpoint\_network\_policies\_enabled) | A map of subnet name to enable/disable private link service network policies on the subnet. | `map(string)` | `{}` | no |
| <a name="input_subnet_names"></a> [subnet\_names](#input\_subnet\_names) | A list of public subnets inside the vNet. | `list(string)` | n/a | yes |
| <a name="input_subnet_prefixes"></a> [subnet\_prefixes](#input\_subnet\_prefixes) | The address prefix to use for the subnet. | `list(string)` | n/a | yes |
| <a name="input_subnet_service_endpoints"></a> [subnet\_service\_endpoints](#input\_subnet\_service\_endpoints) | A map of subnet name to service endpoints to add to the subnet. | `map(any)` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to be associated with the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_resource_group_id"></a> [resource\_group\_id](#output\_resource\_group\_id) | n/a |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | n/a |
| <a name="output_key_vault_id"></a> [key\_vault\_id](#output\_key\_vault\_id) | n/a |
| <a name="output_vault_uri"></a> [vault\_uri](#output\_vault\_uri) | n/a |
| <a name="output_access_policies_object_ids"></a> [access\_policies\_object\_ids](#output\_access\_policies\_object\_ids) | n/a |
| <a name="output_key_vault_name"></a> [key\_vault\_name](#output\_key\_vault\_name) | n/a |
| <a name="output_certificate_ids"></a> [certificate\_ids](#output\_certificate\_ids) | IDs of the certificates from the Key Vault in the reference module |
| <a name="output_secret_ids"></a> [secret\_ids](#output\_secret\_ids) | IDs of the secrets from the Key Vault in the reference module |
| <a name="output_key_ids"></a> [key\_ids](#output\_key\_ids) | IDs of the keys from the Key Vault in the reference module |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
