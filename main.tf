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
  source  = "terraform.registry.launch.nttdata.com/module_library/resource_name/launch"
  version = "~> 2.0"

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

  name     = local.resource_group_name
  location = var.location
  tags     = local.resource_group_tags
}

module "key_vault" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/key_vault/azurerm"
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
  source  = "terraform.registry.launch.nttdata.com/module_primitive/role_assignment/azurerm"
  version = "~> 1.2.1"

  for_each = var.role_assignments

  scope                = module.key_vault.key_vault_id
  role_definition_name = each.value.role_definition_name
  principal_id         = each.value.principal_id
  principal_type       = each.value.principal_type

  depends_on = [module.key_vault]
}

module "secrets" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/key_vault_secret/azurerm"
  version = "~> 1.0"

  for_each = var.secrets

  key_vault_id = module.key_vault.key_vault_id
  name         = each.key
  value        = each.value

  depends_on = [module.role_assignment]
}

module "imported_certificates" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/key_vault_certificate/azurerm"
  version = "~> 1.0"

  for_each = var.certificates

  name         = each.key
  key_vault_id = module.key_vault.key_vault_id

  method = "Import"

  certificate = {
    contents = each.value.filepath != null ? filebase64("${path.root}/${each.value.filepath}") : each.value.contents
    password = each.value.password
  }

  depends_on = [module.role_assignment]
}

module "certificate_issuers" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/key_vault_certificate_issuer/azurerm"
  version = "~> 1.0"

  for_each = var.certificate_issuers

  name         = each.key
  key_vault_id = module.key_vault.key_vault_id

  provider_name = each.value.provider_name
  org_id        = each.value.org_id
  account_id    = each.value.account_id
  password      = each.value.password

  admins = each.value.admins

  depends_on = [module.role_assignment]
}

module "generated_certificates" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/key_vault_certificate/azurerm"
  version = "~> 1.0"

  for_each = var.generated_certificates

  method = "Generate"

  name         = each.key
  key_vault_id = module.key_vault.key_vault_id

  issuer_name                 = each.value.issuer_name
  key_properties              = each.value.key_properties
  lifetime_action             = each.value.lifetime_action
  secret_properties           = each.value.secret_properties
  x509_certificate_properties = each.value.x509_certificate_properties

  depends_on = [module.certificate_issuers]
}

module "private_endpoint" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/private_endpoint/azurerm"
  version = "~> 1.0"

  count = var.public_network_access_enabled ? 0 : 1

  endpoint_name                   = local.endpoint_name
  resource_group_name             = local.resource_group_name
  region                          = var.location
  subnet_id                       = var.subnet_id
  private_dns_zone_group_name     = var.private_dns_zone_group_name
  private_dns_zone_ids            = var.private_dns_zone_ids
  is_manual_connection            = var.is_manual_connection
  private_connection_resource_id  = module.key_vault.key_vault_id
  subresource_names               = var.subresource_names
  request_message                 = var.request_message
  tags                            = local.private_endpoint_tags
  private_service_connection_name = local.private_service_connection_name

  depends_on = [module.key_vault]
}


# Monitor Action Group
module "monitor_action_group" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/monitor_action_group/azurerm"
  version = "~> 1.0.0"

  count               = var.action_group != null ? 1 : 0
  action_group_name   = var.action_group.name
  resource_group_name = local.resource_group_name
  short_name          = var.action_group.short_name
  arm_role_receivers  = var.action_group.arm_role_receivers
  email_receivers     = var.action_group.email_receivers
  tags                = local.resource_group_tags

  depends_on = [module.key_vault]
}


# Monitor Metric Alerts (for Key Vault)
module "monitor_metric_alert" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/monitor_metric_alert/azurerm"
  version = "~> 2.0"

  for_each            = var.metric_alerts
  name                = each.key
  resource_group_name = local.resource_group_name

  scopes = [
    module.key_vault.key_vault_id
  ]

  description        = each.value.description
  frequency          = each.value.frequency
  severity           = each.value.severity
  enabled            = each.value.enabled
  webhook_properties = each.value.webhook_properties
  criteria           = each.value.criteria
  dynamic_criteria   = each.value.dynamic_criteria

  action_group_ids = concat(
    var.action_group != null ? [module.monitor_action_group[0].action_group_id] : [],
    var.action_group_ids
  )

  depends_on = [
    module.key_vault,
    module.monitor_action_group
  ]
}
module "monitor_scheduled_query_alert" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/monitor_scheduled_query_alert/azurerm"
  version = "~> 1.0"

  for_each = var.scheduled_query_alerts

  resource_group_name = local.resource_group_name
  location            = var.location
  alert_name          = each.key

  data_source_id = coalesce(
    each.value.data_source_id,
    var.log_analytics_workspace != null ? module.log_analytics_workspace[0].id : null,
    var.log_analytics_workspace_id
  )

  description             = each.value.description
  enabled                 = each.value.enabled
  query                   = each.value.query
  severity                = each.value.severity
  frequency               = each.value.frequency
  time_window             = each.value.time_window
  authorized_resource_ids = each.value.authorized_resource_ids
  trigger_operator        = each.value.trigger_operator
  trigger_threshold       = each.value.trigger_threshold
  email_subject           = each.value.email_subject
  custom_webhook_payload  = each.value.custom_webhook_payload

  action_group_ids = concat(
    var.action_group != null ? [module.monitor_action_group[0].action_group_id] : [],
    var.action_group_ids,
    each.value.action_group_ids
  )

  depends_on = [
    module.key_vault,
    module.monitor_action_group,
    module.log_analytics_workspace,
    module.diagnostic_setting
  ]
}


# Log Analytics Workspace

module "log_analytics_workspace" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/log_analytics_workspace/azurerm"
  version = "~> 1.0"

  count = var.log_analytics_workspace != null ? 1 : 0

  name                = module.resource_names["log_analytics_workspace"].standard
  location            = var.location
  resource_group_name = local.resource_group_name

  sku                           = var.log_analytics_workspace.sku
  retention_in_days             = var.log_analytics_workspace.retention_in_days
  identity                      = var.log_analytics_workspace.identity
  local_authentication_disabled = var.log_analytics_workspace.local_authentication_disabled

  tags = merge(
    local.resource_group_tags,
    { resource_name = module.resource_names["log_analytics_workspace"].standard }
  )

  depends_on = [module.key_vault]
}


# Diagnostic Settings for Key Vault
module "diagnostic_setting" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/monitor_diagnostic_setting/azurerm"
  version = "~> 3.0"

  for_each = var.diagnostic_settings

  name               = each.key
  target_resource_id = module.key_vault.key_vault_id

  log_analytics_workspace_id = coalesce(
    var.log_analytics_workspace != null ? module.log_analytics_workspace[0].id : null,
    var.log_analytics_workspace_id
  )

  enabled_log = each.value.enabled_log
  metrics     = each.value.metrics

  depends_on = [
    module.key_vault,
    module.log_analytics_workspace
  ]
}
