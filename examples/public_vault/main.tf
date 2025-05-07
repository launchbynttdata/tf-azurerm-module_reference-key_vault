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

data "azurerm_client_config" "current" {}

module "resource_names" {
  source  = "terraform.registry.launch.nttdata.com/module_library/resource_name/launch"
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
  source  = "terraform.registry.launch.nttdata.com/module_primitive/resource_group/azurerm"
  version = "~> 1.0"

  name     = module.resource_names["resource_group_vnet"].minimal_random_suffix
  location = var.location
  tags     = merge(var.tags, { resource_name = module.resource_names["resource_group_vnet"].standard })
}

module "network" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/virtual_network/azurerm"
  version = "~> 2.0"

  use_for_each                                     = var.use_for_each
  vnet_location                                    = var.location
  address_space                                    = var.address_space
  bgp_community                                    = var.bgp_community
  ddos_protection_plan                             = var.ddos_protection_plan
  dns_servers                                      = var.dns_servers
  nsg_ids                                          = var.nsg_ids
  route_tables_ids                                 = var.route_tables_ids
  subnet_delegation                                = var.subnet_delegation
  subnet_private_endpoint_network_policies_enabled = var.subnet_private_endpoint_network_policies_enabled
  subnet_names                                     = var.subnet_names
  subnet_prefixes                                  = var.subnet_prefixes
  subnet_service_endpoints                         = var.subnet_service_endpoints
  resource_group_name                              = module.resource_names["resource_group_vnet"].minimal_random_suffix
  vnet_name                                        = module.resource_names["vnet"].minimal_random_suffix
  tags                                             = merge(var.tags, { resource_name = module.resource_names["vnet"].standard })

  depends_on = [module.resource_group]
}

module "private_dns_zone" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/private_dns_zone/azurerm"
  version = "~> 1.0"

  resource_group_name = module.resource_group.name
  zone_name           = var.zone_name
  tags                = var.tags

  depends_on = [module.resource_group]
}

module "key_vault" {
  source = "../.."

  location                = var.location
  resource_names_map      = var.resource_names_map
  environment             = var.environment
  environment_number      = var.environment_number
  resource_number         = var.resource_number
  logical_product_family  = var.logical_product_family
  logical_product_service = var.logical_product_service
  use_azure_region_abbr   = var.use_azure_region_abbr

  enabled_for_deployment          = var.enabled_for_deployment
  enabled_for_template_deployment = var.enabled_for_template_deployment
  soft_delete_retention_days      = var.soft_delete_retention_days
  purge_protection_enabled        = var.purge_protection_enabled
  sku_name                        = var.sku_name
  access_policies                 = var.access_policies
  enable_rbac_authorization       = var.enable_rbac_authorization
  network_acls                    = var.network_acls
  public_network_access_enabled   = var.public_network_access_enabled

  role_assignments = local.role_assignments

  subnet_id                   = module.network.vnet_subnets[0]
  private_dns_zone_group_name = var.private_dns_zone_group_name
  private_dns_zone_ids        = [module.private_dns_zone.id]
  is_manual_connection        = var.is_manual_connection
  subresource_names           = var.subresource_names
  request_message             = var.request_message
  certificates                = var.certificates
  secrets                     = var.secrets

  certificate_issuers    = var.certificate_issuers
  generated_certificates = var.generated_certificates

  tags = merge(var.tags, { resource_name = module.resource_names["key_vault"].standard })

  depends_on = [module.network, module.private_dns_zone]
}
