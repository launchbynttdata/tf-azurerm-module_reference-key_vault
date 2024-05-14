locals {


  resource_group_name             = module.resource_names["resource_group"].standard
  key_vault_name                  = module.resource_names["key_vault"].recommended_per_length_restriction
  endpoint_name                   = module.resource_names["private_endpoint"].standard
  private_service_connection_name = module.resource_names["private_service_connection"].standard

  default_tags = {
    "provisioner" = "terraform"
  }

  key_vault_tags        = merge({ resource_name = local.key_vault_name }, local.default_tags, var.tags)
  resource_group_tags   = merge({ resource_name = local.resource_group_name }, local.default_tags, var.tags)
  private_dns_zone_tags = merge({ resource_name = var.zone_name }, local.default_tags, var.tags)
  private_endpoint_tags = merge({ resource_name = local.endpoint_name }, local.default_tags, var.tags)

  private_dns_zone_link_tags = {
    for key, value in var.additional_vnet_links : key => merge({ resource_name = key }, local.default_tags, var.tags)
  }
  resource_group = {
    name     = local.resource_group_name
    location = var.location
  }

  role_assignments = {
    for key, value in var.role_assignments : key => merge(value, { scope = module.key_vault.key_vault_id })
  }

}
