enabled_for_deployment          = false
enabled_for_template_deployment = false
soft_delete_retention_days      = 7
purge_protection_enabled        = false
sku_name                        = "standard"
access_policies                 = {}
enable_rbac_authorization       = false
# Certificates to be imported into the Key Vault
certificates = {
  "example_cert_1" = {
    filepath = "dummy-cert.pfx"
    password = ""
  }
}
secrets = {
  "example_secret_1" = "secret_value_1"
  "example_secret_2" = "secret_value_2"
}
network_acls = {
  bypass                     = "AzureServices"
  default_action             = "Allow"
  ip_rules                   = []
  virtual_network_subnet_ids = []
}
public_network_access_enabled = true

environment                 = "sandbox"
environment_number          = "000"
resource_number             = "000"
logical_product_family      = "launch"
logical_product_service     = "vault"
use_azure_region_abbr       = true
location                    = "eastus"
role_assignments            = {}
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

tags = {
  Purpose = "Terraform Examples"
}
