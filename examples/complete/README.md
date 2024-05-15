# Complete example
 This module emulates a Hub and Spoke architecture model by creating multiple Vnets and subnets using same terraform module. Each Vnet is created in its own Resource Group. The Vnet attributes are configurable through the input parameters

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | <= 1.5.5 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.77 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.103.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_key_vault"></a> [key\_vault](#module\_key\_vault) | ../.. | n/a |
| <a name="module_network"></a> [network](#module\_network) | d2lqlh14iel5k2.cloudfront.net/module_primitive/virtual_network/azurerm | ~> 2.0 |
| <a name="module_resource_names"></a> [resource\_names](#module\_resource\_names) | d2lqlh14iel5k2.cloudfront.net/module_library/resource_name/launch | ~> 1.0 |
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | d2lqlh14iel5k2.cloudfront.net/module_primitive/resource_group/azurerm | ~> 1.0 |

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
| <a name="input_resource_names_map"></a> [resource\_names\_map](#input\_resource\_names\_map) | A map of key to resource\_name that will be used by tf-launch-module\_library-resource\_name to generate resource names | <pre>map(object({<br>    name       = string<br>    max_length = optional(number, 60)<br>  }))</pre> | `{}` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment in which the resource should be provisioned like dev, qa, prod etc. | `string` | n/a | yes |
| <a name="input_environment_number"></a> [environment\_number](#input\_environment\_number) | The environment count for the respective environment. Defaults to 000. Increments in value of 1 | `string` | `"000"` | no |
| <a name="input_resource_number"></a> [resource\_number](#input\_resource\_number) | The resource count for the respective resource. Defaults to 000. Increments in value of 1 | `string` | `"000"` | no |
| <a name="input_logical_product_family"></a> [logical\_product\_family](#input\_logical\_product\_family) | (Required) Name of the product family for which the resource is created.<br>    Example: org\_name, department\_name. | `string` | n/a | yes |
| <a name="input_logical_product_service"></a> [logical\_product\_service](#input\_logical\_product\_service) | (Required) Name of the product service for which the resource is created.<br>    For example, backend, frontend, middleware etc. | `string` | n/a | yes |
| <a name="input_use_azure_region_abbr"></a> [use\_azure\_region\_abbr](#input\_use\_azure\_region\_abbr) | Use Azure region abbreviation in the resource name | `bool` | `true` | no |
| <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments) | A map of role assignments to be created | <pre>map(object({<br>    name                 = optional(string)<br>    scope                = optional(string)<br>    role_definition_name = string<br>    principal_id         = optional(string)<br>  }))</pre> | `{}` | no |
| <a name="input_zone_name"></a> [zone\_name](#input\_zone\_name) | Name of the private dns zone. For public cloud, the default value is `privatelink.vaultcore.azure.net` and for sovereign clouds, the default value is `privatelink.vaultcore.usgovcloudapi.net` | `string` | `"privatelink.vaultcore.azure.net"` | no |
| <a name="input_soa_record"></a> [soa\_record](#input\_soa\_record) | n/a | <pre>object({<br>    email        = string<br>    expire_time  = number<br>    minimum_ttl  = number<br>    refresh_time = number<br>    retry_time   = number<br>    ttl          = number<br>    tags         = map(string)<br>  })</pre> | `null` | no |
| <a name="input_additional_vnet_links"></a> [additional\_vnet\_links](#input\_additional\_vnet\_links) | The list of Virtual Network ids that should be linked to the DNS Zone. Changing this forces a new resource to be created. | `map(string)` | `{}` | no |
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
| <a name="input_vnet_name"></a> [vnet\_name](#input\_vnet\_name) | Name of the vnet | `string` | n/a | yes |
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
| <a name="output_private_dns_zone_id"></a> [private\_dns\_zone\_id](#output\_private\_dns\_zone\_id) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
