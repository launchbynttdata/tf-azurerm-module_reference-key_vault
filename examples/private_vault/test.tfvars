enabled_for_deployment          = false
enabled_for_template_deployment = false
soft_delete_retention_days      = 7
purge_protection_enabled        = false
sku_name                        = "standard"
access_policies                 = {}
enable_rbac_authorization       = true
role_assignment_type            = "User"
network_acls = {
  bypass                     = "AzureServices"
  default_action             = "Allow"
  ip_rules                   = []
  virtual_network_subnet_ids = []
}
public_network_access_enabled = false

environment                 = "sandbox"
environment_number          = "000"
resource_number             = "000"
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
subnet_private_endpoint_network_policies_enabled = {
  private-endpoint-sbnt = false
}

tags = {
  Purpose = "Terraform Examples"
}

# Action Group

action_group = {
  name       = "kv-example-ag"
  short_name = "kvexag"

  email_receivers = [
    {
      name          = "admin"
      email_address = "your-email@domain.com"
    }
  ]
}


# Metric Alerts

metric_alerts = {
  kv_availability_alert = {
    description = "Alert when Key Vault availability drops"
    severity    = 3
    enabled     = true
    frequency   = "PT1M"

    criteria = [
      {
        metric_namespace = "Microsoft.KeyVault/vaults"
        metric_name      = "Availability"
        aggregation      = "Average"
        operator         = "LessThan"
        threshold        = 99
      }
    ]
  }
}

scheduled_query_alerts = {
  kv_secret_operation_failures = {
    description            = "Alert when Key Vault secret operations fail"
    severity               = 2
    enabled                = true
    frequency              = 5
    time_window            = 30
    trigger_operator       = "GreaterThan"
    trigger_threshold      = 0
    email_subject          = "Key Vault secret operation failures detected"
    custom_webhook_payload = "{\"alertType\":\"scheduled-query\",\"service\":\"key-vault\"}"
    query                  = <<-QUERY
      AzureDiagnostics
      | where ResourceProvider == "MICROSOFT.KEYVAULT"
      | where Category == "AuditEvent"
      | where OperationName has "Secret"
      | where ResultType != "Success"
      | summarize FailureCount = count() by bin(TimeGenerated, 5m)
    QUERY
  }
}

# Log Analytics Workspace
log_analytics_workspace = {
  sku               = "PerGB2018"
  retention_in_days = 30
  daily_quota_gb    = 1
}

# Diagnostic Settings
diagnostic_settings = {
  kv_diagnostics = {
    enabled_log = [
      {
        category_group = "allLogs"
      }
    ]

    metrics = [
      {
        category = "AllMetrics"
        enabled  = true
      }
    ]
  }
}
