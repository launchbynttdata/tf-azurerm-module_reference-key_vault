enabled_for_deployment          = false
enabled_for_template_deployment = false
soft_delete_retention_days      = 7
purge_protection_enabled        = false
sku_name                        = "standard"
access_policies                 = {}
enable_rbac_authorization       = true
network_acls = {
  bypass                     = "AzureServices"
  default_action             = "Allow"
  ip_rules                   = []
  virtual_network_subnet_ids = []
}
public_network_access_enabled = false
resource_names_map = {
  key_vault = {
    name       = "kv"
    max_length = 24
  }
  resource_group = {
    name       = "rg"
    max_length = 80
  }
  resource_group_vnet = {
    name       = "vnetrg"
    max_length = 80
  }
  private_service_connection = {
    name       = "pesc"
    max_length = 80
  }
  private_endpoint = {
    name       = "pe"
    max_length = 80
  }
  private_dns_zone_link = {
    name       = "pdzl"
    max_length = 80
  }
}
environment             = "sandbox"
environment_number      = "000"
resource_number         = "000"
logical_product_family  = "launch"
logical_product_service = "vault"
use_azure_region_abbr   = true
location                = "eastus"
role_assignments = {
  "kv_admin" = {
    role_definition_name = "Key Vault Administrator"
  }
}
zone_name                   = "privatelink.vaultcore.azure.net"
soa_record                  = null
private_dns_zone_group_name = "vault"
is_manual_connection        = false
subresource_names           = ["vault"]
request_message             = null
//Variables for networking module
address_space            = ["10.32.52.0/23"]
subnet_names             = ["private-endpoint-sbnt"]
subnet_prefixes          = ["10.32.52.32/28"]
bgp_community            = null
ddos_protection_plan     = null
dns_servers              = []
nsg_ids                  = {}
route_tables_ids         = {}
subnet_delegation        = {}
subnet_service_endpoints = {}
use_for_each             = true
subnet_private_endpoint_network_policies_enabled = {
  private-endpoint-sbnt = false
}
vnet_name = "vnet1"
tags = {
  "test_tag" = "test_value"
}
