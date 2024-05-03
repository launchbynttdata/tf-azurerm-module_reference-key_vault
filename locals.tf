locals {
  default_tags = {
    "provisioner" = "terraform"
  }

  key_vault_tags             = merge(var.custom_tags, local.default_tags)
  resource_group_tags        = merge(var.resource_group_tags, local.default_tags)
  private_dns_zone_link_tags = merge(var.private_dns_zone_link_vnet_tags, local.default_tags)
  private_dns_zone_tags      = merge(var.private_dns_zone_tags, local.default_tags)
  private_endpoint_tags      = merge(var.private_endpoint_tags, local.default_tags)

  resource_group_name             = module.resource_names["resource_group"].standard
  key_vault_name                  = module.resource_names["key_vault"].recommended_per_length_restriction
  private_dns_zone_link_name      = module.resource_names["private_dns_zone_link"].standard
  endpoint_name                   = module.resource_names["private_endpoint"].standard
  private_service_connection_name = module.resource_names["private_service_connection"].standard

  resource_group = {
    name     = local.resource_group_name
    location = var.location
  }

  # role_assignments = {
  #   for key, value in var.role_assignments : key => merge(value, { scope = module.key_vault.key_vault_id })
  # }

}
