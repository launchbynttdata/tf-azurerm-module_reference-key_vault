// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

module "resource_names" {
  source  = "d2lqlh14iel5k2.cloudfront.net/module_library/resource_name/launch"
  version = "~> 1.0"

  for_each = var.resource_names_map

  region                  = join("", split("-", var.location))
  class_env               = var.environment
  cloud_resource_type     = each.value.name
  instance_env            = var.environment_number
  instance_resource       = var.resource_number
  maximum_length          = each.value.max_length
  logical_product_family  = var.logical_product_family
  logical_product_service = var.logical_product_service
  use_azure_region_abbr   = var.use_azure_region_abbr
}

module "resource_group" {
  source  = "d2lqlh14iel5k2.cloudfront.net/module_primitive/resource_group/azurerm"
  version = "~> 1.0"

  name     = local.resource_group_name
  location = var.location
  tags     = local.resource_group_tags
}

module "key_vault" {
  source  = "d2lqlh14iel5k2.cloudfront.net/module_primitive/key_vault/azurerm"
  version = "~> 2.0"

  resource_group = local.resource_group
  key_vault_name = local.key_vault_name

  enabled_for_deployment          = var.enabled_for_deployment
  enabled_for_template_deployment = var.enabled_for_template_deployment
  soft_delete_retention_days      = var.soft_delete_retention_days
  purge_protection_enabled        = var.purge_protection_enabled
  sku_name                        = var.sku_name
  enable_rbac_authorization       = var.enable_rbac_authorization
  public_network_access_enabled   = var.public_network_access_enabled

  network_acls    = var.network_acls
  access_policies = var.access_policies
  custom_tags     = local.key_vault_tags

  depends_on = [module.resource_group]
}

module "role_assignment" {
  source  = "d2lqlh14iel5k2.cloudfront.net/module_primitive/role_assignment/azurerm"
  version = "~> 1.0"

  for_each = var.role_assignments

  scope                = module.key_vault.key_vault_id
  role_definition_name = each.value.role_definition_name
  principal_id         = each.value.principal_id

  depends_on = [module.key_vault]
}

module "private_dns_zone" {
  source  = "d2lqlh14iel5k2.cloudfront.net/module_primitive/private_dns_zone/azurerm"
  version = "~> 1.0"

  count = var.public_network_access_enabled ? 0 : 1

  resource_group_name = local.resource_group_name
  zone_name           = var.zone_name
  soa_record          = var.soa_record
  tags                = local.private_dns_zone_tags

  depends_on = [module.resource_group]
}

module "private_dns_zone_link_vnet" {
  source  = "d2lqlh14iel5k2.cloudfront.net/module_primitive/private_dns_vnet_link/azurerm"
  version = "~> 1.0"

  count = var.public_network_access_enabled ? 0 : 1

  link_name             = "private_endpoint_vnet_link"
  resource_group_name   = local.resource_group_name
  private_dns_zone_name = module.private_dns_zone[0].zone_name
  virtual_network_id    = local.vnet_id
  registration_enabled  = false
  tags                  = merge({ resource_name = "private_endpoint_vnet_link" }, local.default_tags, var.tags)

  depends_on = [module.resource_group]

}

module "additional_vnet_links" {
  source  = "d2lqlh14iel5k2.cloudfront.net/module_primitive/private_dns_vnet_link/azurerm"
  version = "~> 1.0"

  for_each = var.public_network_access_enabled ? {} : var.additional_vnet_links

  link_name             = each.key
  resource_group_name   = local.resource_group_name
  private_dns_zone_name = module.private_dns_zone[0].zone_name
  virtual_network_id    = each.value
  registration_enabled  = false
  tags                  = merge({ resource_name = each.key }, local.default_tags, var.tags)

  depends_on = [module.resource_group]

}

module "private_endpoint" {
  source  = "d2lqlh14iel5k2.cloudfront.net/module_primitive/private_endpoint/azurerm"
  version = "~> 1.0"

  count = var.public_network_access_enabled ? 0 : 1

  endpoint_name                   = local.endpoint_name
  resource_group_name             = local.resource_group_name
  region                          = var.location
  subnet_id                       = var.subnet_id
  private_dns_zone_group_name     = var.private_dns_zone_group_name
  private_dns_zone_ids            = [module.private_dns_zone[0].id]
  is_manual_connection            = var.is_manual_connection
  private_connection_resource_id  = module.key_vault.key_vault_id
  subresource_names               = var.subresource_names
  request_message                 = var.request_message
  tags                            = local.private_endpoint_tags
  private_service_connection_name = local.private_service_connection_name

  depends_on = [module.resource_group]
}
