enabled_for_deployment          = false
enabled_for_template_deployment = false
soft_delete_retention_days      = 7
purge_protection_enabled        = false
sku_name                        = "standard"
access_policies                 = {}
enable_rbac_authorization       = true
role_assignment_type            = "User"
public_network_access_enabled   = true
secrets = {
  "example-secret-1" = "secret_value_1"
  "example-secret-2" = "secret_value_2"
}
certificate_issuers = {
  "example-digicert-tls-issuer" = {
    provider_name = "DigiCert"
    org_id        = "000000"
    account_id    = "12345"
    password      = "password12345" // pragma: allowlist secret
    admins = [
      {
        email_address = "terratest@launchdso.nttdata.com"
        first_name    = "Terratest"
      }
    ]
  }
}
generated_certificates = {
  "example-self-signed-certificate" = {
    issuer_name = "Self"

    x509_certificate_properties = {
      key_usage          = ["digitalSignature", "nonRepudiation", "keyCertSign", "keyEncipherment", "dataEncipherment"]
      subject            = "CN=Launch DSO Test Certificate"
      validity_in_months = 12
      subject_alternate_names = {
        emails    = ["test@launchdso.nttdata.com"]
        dns_names = ["launchdso.nttdata.com"]
      }
    }
  }
}
environment                 = "sandbox"
environment_number          = "000"
resource_number             = "001"
logical_product_family      = "launch"
logical_product_service     = "vault"
use_azure_region_abbr       = true
location                    = "eastus"
role_assignments            = {}
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
