# tf-azurerm-module_reference-key_vault

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![License: CC BY-NC-ND 4.0](https://img.shields.io/badge/License-CC_BY--NC--ND_4.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc-nd/4.0/)

## Overview

This reference architecture module provisions a Key Vault in its own Resource Group. Based on the inputs provided, it can also
provision a Private Key Vault with private endpoints in a provided subnet.

The module also supports Azure Monitor integration through action groups, metric alerts, diagnostic settings, Log Analytics
workspaces, and scheduled query alerts for Key Vault log-based detections.

## Upgrading from 2.x

3.0.0 moves the module to azurerm v4, and moves the composed `monitor_scheduled_query_alert` primitive
from 1.x to 2.x, which replaces `azurerm_monitor_scheduled_query_rules_alert` with
`azurerm_monitor_scheduled_query_rules_alert_v2`. The azurerm constraint moves from `~> 3.77` to
`>= 4.69, < 5.0`, because 4.69 is where the provider added `email_subject` to the v2 `action` block.

Every other composed primitive moves to its current major. Their inputs, outputs and resource
addresses are unchanged across those bumps, so the bumps alone move nothing in state. Moving from
azurerm 3.x to 4.x can still change other resources, so read your own plan before applying.

### `scheduled_query_alerts` is a different shape

Every alert field except `description`, `enabled`, `severity` and `action_group_ids` changed. The map
now takes a nested `criteria` object instead of flat `query` / `trigger_*` fields, and ISO 8601
durations instead of minutes:

| 2.x | 3.x |
|-----|-----|
| `query`, `trigger_operator`, `trigger_threshold` | `criteria.query`, `criteria.operator`, `criteria.threshold`, plus `criteria.time_aggregation_method` |
| `frequency` (minutes) | `evaluation_frequency` (ISO 8601, e.g. `PT5M`) |
| `time_window` (minutes) | `window_duration` (ISO 8601, e.g. `PT30M`) |
| `data_source_id` | `scope_id` |
| `custom_webhook_payload` (JSON string) | `custom_properties` (`map(string)`) |
| `authorized_resource_ids` | `identity` |
| `email_subject`, default `"Alert Notification"` | `email_subject`, default unset |
| — | `criteria.dimensions`, `criteria.failing_periods`, `criteria.metric_measure_column`, `criteria.resource_id_column` |
| — | `display_name`, `auto_mitigation_enabled`, `mute_actions_after_alert_duration`, `query_time_range_override`, `skip_query_validation`, `target_resource_types`, `workspace_alerts_storage_enabled` |

With the default `criteria.time_aggregation_method` of `Count`, the threshold is compared with the
number of rows the query returns, as the 2.x trigger was.

`custom_properties` is a replacement rather than a rename: the 2.x value was the entire webhook JSON
body, while `custom_properties` is a flat map of properties added to Azure's own alert payload.

`identity` replaces `authorized_resource_ids`: the rule queries as that managed identity, so grant it
Reader on every resource a cross-resource query reads. The `scheduled_query_alert_principal_ids` output
gives the principal of a SystemAssigned identity.

An unset `email_subject` leaves the subject to Azure. Set it to keep the 2.x `"Alert Notification"`
subject.

### The alerts are replaced, not updated

The underlying resource type changes, so no `moved` block can carry state. Terraform destroys each
2.x rule and creates a v2 one, losing the alert history.

Both Terraform resource types manage the same ARM resource type,
`Microsoft.Insights/scheduledQueryRules`, and differ only in API version. An old rule and a v2 rule
with the same name are therefore the same ARM ID. The v2 create fails the provider's import check
while a rule already exists at that ID, and Terraform does not order the old destroy before the v2
create, because they are separate resources with no dependency between them. A replacement that keeps
the same alert name therefore depends on timing. Each alert is named after its
`scheduled_query_alerts` key, so **changing the key is the simplest way to get a new name**.
Otherwise, apply 2.x with the alerts removed from `scheduled_query_alerts`, then upgrade and add them
back.

### Queries are validated against the scope

Azure checks `criteria.query` against the scope's schema on create, so a query referencing a table
the scope has no schema for is rejected at apply time. A workspace this module creates has no
`AzureDiagnostics` table until Key Vault diagnostics have arrived, which is after the alerts are
created, so set `skip_query_validation` on alerts that query it. The examples do. A query that splits
by a column must project that column, and one that aggregates a value must project its
`metric_measure_column`.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.5 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.69, < 5.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_certificate_issuers"></a> [certificate\_issuers](#module\_certificate\_issuers) | terraform.registry.launch.nttdata.com/module_primitive/key_vault_certificate_issuer/azurerm | ~> 2.1 |
| <a name="module_diagnostic_setting"></a> [diagnostic\_setting](#module\_diagnostic\_setting) | terraform.registry.launch.nttdata.com/module_primitive/monitor_diagnostic_setting/azurerm | ~> 5.0 |
| <a name="module_generated_certificates"></a> [generated\_certificates](#module\_generated\_certificates) | terraform.registry.launch.nttdata.com/module_primitive/key_vault_certificate/azurerm | ~> 2.1 |
| <a name="module_imported_certificates"></a> [imported\_certificates](#module\_imported\_certificates) | terraform.registry.launch.nttdata.com/module_primitive/key_vault_certificate/azurerm | ~> 2.1 |
| <a name="module_key_vault"></a> [key\_vault](#module\_key\_vault) | terraform.registry.launch.nttdata.com/module_primitive/key_vault/azurerm | ~> 3.1 |
| <a name="module_log_analytics_workspace"></a> [log\_analytics\_workspace](#module\_log\_analytics\_workspace) | terraform.registry.launch.nttdata.com/module_primitive/log_analytics_workspace/azurerm | ~> 2.0 |
| <a name="module_monitor_action_group"></a> [monitor\_action\_group](#module\_monitor\_action\_group) | terraform.registry.launch.nttdata.com/module_primitive/monitor_action_group/azurerm | ~> 1.2 |
| <a name="module_monitor_metric_alert"></a> [monitor\_metric\_alert](#module\_monitor\_metric\_alert) | terraform.registry.launch.nttdata.com/module_primitive/monitor_metric_alert/azurerm | ~> 3.0 |
| <a name="module_monitor_scheduled_query_alert"></a> [monitor\_scheduled\_query\_alert](#module\_monitor\_scheduled\_query\_alert) | terraform.registry.launch.nttdata.com/module_primitive/monitor_scheduled_query_alert/azurerm | ~> 2.0 |
| <a name="module_private_endpoint"></a> [private\_endpoint](#module\_private\_endpoint) | terraform.registry.launch.nttdata.com/module_primitive/private_endpoint/azurerm | ~> 3.0 |
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | terraform.registry.launch.nttdata.com/module_primitive/resource_group/azurerm | ~> 2.0 |
| <a name="module_resource_names"></a> [resource\_names](#module\_resource\_names) | terraform.registry.launch.nttdata.com/module_library/resource_name/launch | ~> 2.0 |
| <a name="module_role_assignment"></a> [role\_assignment](#module\_role\_assignment) | terraform.registry.launch.nttdata.com/module_primitive/role_assignment/azurerm | ~> 2.0 |
| <a name="module_secrets"></a> [secrets](#module\_secrets) | terraform.registry.launch.nttdata.com/module_primitive/key_vault_secret/azurerm | ~> 2.1 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_policies"></a> [access\_policies](#input\_access\_policies) | Additional Access policies for the vault except the current user which are added by default.<br/>    Required only when enable\_rbac\_authorization is set to false. | <pre>map(object({<br/>    object_id               = string<br/>    tenant_id               = string<br/>    key_permissions         = list(string)<br/>    certificate_permissions = list(string)<br/>    secret_permissions      = list(string)<br/>    storage_permissions     = list(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_action_group"></a> [action\_group](#input\_action\_group) | An action group object. Each action group can have:<br/>  - short\_name: (Required) The short name of the action group<br/>  - arm\_role\_receivers: (Optional) List of ARM role receivers<br/>  - email\_receivers: (Optional) List of email receivers | <pre>object({<br/>    name       = string<br/>    short_name = string<br/><br/>    arm_role_receivers = optional(list(object({<br/>      name                    = string<br/>      role_id                 = string<br/>      use_common_alert_schema = optional(bool)<br/>    })), [])<br/><br/>    email_receivers = optional(list(object({<br/>      name                    = string<br/>      email_address           = string<br/>      use_common_alert_schema = optional(bool)<br/>    })), [])<br/>  })</pre> | `null` | no |
| <a name="input_action_group_ids"></a> [action\_group\_ids](#input\_action\_group\_ids) | A list of action group IDs. | `list(string)` | `[]` | no |
| <a name="input_certificate_issuers"></a> [certificate\_issuers](#input\_certificate\_issuers) | List of certificate issuers to be created | <pre>map(object({<br/>    provider_name = string<br/>    org_id        = string<br/>    account_id    = string<br/>    password      = string<br/><br/>    admins = optional(list(object({<br/>      email_address = string<br/>      first_name    = optional(string)<br/>      last_name     = optional(string)<br/>      phone         = optional(string)<br/>    })), [])<br/>  }))</pre> | `{}` | no |
| <a name="input_certificates"></a> [certificates](#input\_certificates) | List of certificates to be imported. If `filepath` is specified then the pfx files should be present in the root of the module (path.root). If `content` is specified then the content of the certificate should be provided in base 64 encoded format. Only one of them should be provided. | <pre>map(object({<br/>    contents = optional(string)<br/>    filepath = optional(string)<br/>    password = optional(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_diagnostic_settings"></a> [diagnostic\_settings](#input\_diagnostic\_settings) | n/a | <pre>map(object({<br/><br/>    enabled_log = optional(list(object({<br/>      category_group = optional(string, "allLogs")<br/>      category       = optional(string, null)<br/>    })))<br/><br/>    metrics = optional(list(object({<br/>      category = string<br/>      enabled  = optional(bool)<br/>    })))<br/><br/>  }))</pre> | `{}` | no |
| <a name="input_enable_rbac_authorization"></a> [enable\_rbac\_authorization](#input\_enable\_rbac\_authorization) | Enable RBAC authorization for the key vault | `bool` | `false` | no |
| <a name="input_enabled_for_deployment"></a> [enabled\_for\_deployment](#input\_enabled\_for\_deployment) | If Azure VM is permitted to retrieve secrets | `bool` | `false` | no |
| <a name="input_enabled_for_template_deployment"></a> [enabled\_for\_template\_deployment](#input\_enabled\_for\_template\_deployment) | If Azure RM is permitted to retrieve secrets | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment in which the resource should be provisioned like dev, qa, prod etc. | `string` | n/a | yes |
| <a name="input_environment_number"></a> [environment\_number](#input\_environment\_number) | The environment count for the respective environment. Defaults to 000. Increments in value of 1 | `string` | `"000"` | no |
| <a name="input_generated_certificates"></a> [generated\_certificates](#input\_generated\_certificates) | List of certificates to be generated using an issuer. | <pre>map(object({<br/>    issuer_name = string<br/><br/>    key_properties = optional(object({<br/>      exportable = bool<br/>      reuse_key  = bool<br/>      key_type   = string<br/><br/>      key_size = optional(number)<br/>      curve    = optional(string)<br/>      }), {<br/>      exportable = true<br/>      key_type   = "RSA"<br/>      key_size   = 2048<br/>      reuse_key  = false<br/>    })<br/><br/>    lifetime_action = optional(object({<br/>      action = object({<br/>        action_type = string<br/>      })<br/>      trigger = object({<br/>        lifetime_percentage = optional(number)<br/>        days_before_expiry  = optional(number)<br/>      })<br/>    }))<br/><br/>    secret_properties = optional(object({<br/>      content_type = string<br/>      }), {<br/>      content_type = "application/x-pkcs12"<br/>    })<br/><br/>    x509_certificate_properties = optional(object({<br/>      key_usage          = list(string)<br/>      extended_key_usage = optional(list(string))<br/>      subject            = string<br/>      validity_in_months = number<br/>      subject_alternative_names = optional(object({<br/>        dns_names = optional(list(string))<br/>        emails    = optional(list(string))<br/>        upns      = optional(list(string))<br/>      }))<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_is_manual_connection"></a> [is\_manual\_connection](#input\_is\_manual\_connection) | Does the Private Endpoint require Manual Approval from the remote resource owner? Changing this forces a new resource<br/>    to be created. | `bool` | `false` | no |
| <a name="input_key_vault_name"></a> [key\_vault\_name](#input\_key\_vault\_name) | (Optional) If specified, this module will use this name for key vault else the naming module will create a name.<br/>    Length must be less than 24 characters | `string` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | Location of the resource group and other services in this module. | `string` | n/a | yes |
| <a name="input_log_analytics_workspace"></a> [log\_analytics\_workspace](#input\_log\_analytics\_workspace) | n/a | <pre>object({<br/><br/>    sku               = string<br/>    retention_in_days = number<br/>    daily_quota_gb    = number<br/><br/>    identity = optional(object({<br/>      type         = string<br/>      identity_ids = optional(list(string))<br/>    }))<br/><br/>    local_authentication_disabled = optional(bool)<br/><br/>  })</pre> | `null` | no |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | (Optional) The ID of the Log Analytics Workspace. | `string` | `null` | no |
| <a name="input_logical_product_family"></a> [logical\_product\_family](#input\_logical\_product\_family) | (Required) Name of the product family for which the resource is created.<br/>    Example: org\_name, department\_name. | `string` | n/a | yes |
| <a name="input_logical_product_service"></a> [logical\_product\_service](#input\_logical\_product\_service) | (Required) Name of the product service for which the resource is created.<br/>    For example, backend, frontend, middleware etc. | `string` | n/a | yes |
| <a name="input_metric_alerts"></a> [metric\_alerts](#input\_metric\_alerts) | n/a | <pre>map(object({<br/><br/>    description        = string<br/>    action_groups      = optional(set(string), [])<br/>    frequency          = optional(string, "PT1M")<br/>    severity           = optional(number, 3)<br/>    enabled            = optional(bool, true)<br/>    webhook_properties = optional(map(string))<br/><br/>    criteria = optional(list(object({<br/>      metric_namespace       = string<br/>      metric_name            = string<br/>      aggregation            = string<br/>      operator               = string<br/>      threshold              = number<br/>      skip_metric_validation = optional(bool, false)<br/><br/>      dimensions = optional(list(object({<br/>        name     = string<br/>        operator = string<br/>        values   = list(string)<br/>      })))<br/>    })))<br/><br/>    dynamic_criteria = optional(object({<br/>      metric_namespace       = string<br/>      metric_name            = string<br/>      aggregation            = string<br/>      operator               = string<br/>      alert_sensitivity      = string<br/>      ignore_data_before     = optional(string)<br/>      skip_metric_validation = optional(bool, false)<br/><br/>      dimensions = optional(list(object({<br/>        name     = string<br/>        operator = string<br/>        values   = list(string)<br/>      })))<br/>    }))<br/><br/>  }))</pre> | `{}` | no |
| <a name="input_network_acls"></a> [network\_acls](#input\_network\_acls) | Network ACLs for the key vault | <pre>object({<br/>    bypass                     = string<br/>    default_action             = string<br/>    ip_rules                   = optional(list(string))<br/>    virtual_network_subnet_ids = optional(list(string))<br/>  })</pre> | <pre>{<br/>  "bypass": "AzureServices",<br/>  "default_action": "Allow",<br/>  "ip_rules": [],<br/>  "virtual_network_subnet_ids": []<br/>}</pre> | no |
| <a name="input_private_dns_zone_group_name"></a> [private\_dns\_zone\_group\_name](#input\_private\_dns\_zone\_group\_name) | Specifies the Name of the Private DNS Zone Group. | `string` | `"vault"` | no |
| <a name="input_private_dns_zone_ids"></a> [private\_dns\_zone\_ids](#input\_private\_dns\_zone\_ids) | A list of Private DNS Zone IDs to link with the Private Endpoint. | `list(string)` | `[]` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | (Optional) Whether public network access is allowed for this Key Vault. Defaults to true. If false, then only private<br/>    endpoints can access the Key Vault. | `bool` | `true` | no |
| <a name="input_purge_protection_enabled"></a> [purge\_protection\_enabled](#input\_purge\_protection\_enabled) | If purge\_protection is enabled | `bool` | `false` | no |
| <a name="input_request_message"></a> [request\_message](#input\_request\_message) | A message passed to the owner of the remote resource when the private endpoint attempts to establish the connection<br/>    to the remote resource. The request message can be a maximum of 140 characters in length.<br/>    Only valid if `is_manual_connection=true` | `string` | `""` | no |
| <a name="input_resource_names_map"></a> [resource\_names\_map](#input\_resource\_names\_map) | A map of key to resource\_name that will be used by tf-launch-module\_library-resource\_name to generate resource names | <pre>map(object({<br/>    name       = string<br/>    max_length = optional(number, 60)<br/>  }))</pre> | <pre>{<br/>  "diagnostic_setting": {<br/>    "max_length": 80,<br/>    "name": "ds"<br/>  },<br/>  "key_vault": {<br/>    "max_length": 24,<br/>    "name": "kv"<br/>  },<br/>  "log_analytics_workspace": {<br/>    "max_length": 80,<br/>    "name": "law"<br/>  },<br/>  "private_endpoint": {<br/>    "max_length": 80,<br/>    "name": "pe"<br/>  },<br/>  "private_service_connection": {<br/>    "max_length": 80,<br/>    "name": "pesc"<br/>  },<br/>  "resource_group": {<br/>    "max_length": 80,<br/>    "name": "rg"<br/>  }<br/>}</pre> | no |
| <a name="input_resource_number"></a> [resource\_number](#input\_resource\_number) | The resource count for the respective resource. Defaults to 000. Increments in value of 1 | `string` | `"000"` | no |
| <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments) | A map of role assignments to be created | <pre>map(object({<br/>    role_definition_name = string<br/>    principal_id         = string<br/>    principal_type       = string<br/>  }))</pre> | `{}` | no |
| <a name="input_scheduled_query_alerts"></a> [scheduled\_query\_alerts](#input\_scheduled\_query\_alerts) | Map of scheduled query alerts to create. Each key is used as the alert name. The shape follows<br/>azurerm\_monitor\_scheduled\_query\_rules\_alert\_v2; see the monitor\_scheduled\_query\_alert primitive for<br/>the per-field detail, which this module passes through and does not re-validate.<br/><br/>scope\_id:         Resource the rule queries. Defaults to the Log Analytics workspace this module<br/>                  creates, then to log\_analytics\_workspace\_id.<br/>action\_group\_ids: Action groups for this alert only, added to the module's action\_group and<br/>                  action\_group\_ids.<br/><br/>criteria.query must be valid against the scope's schema, because Azure checks it on create unless<br/>skip\_query\_validation is true. A query that splits by a column must project that column, and one<br/>that aggregates a value must project the metric\_measure\_column. | <pre>map(object({<br/>    scope_id     = optional(string)<br/>    description  = optional(string, "")<br/>    display_name = optional(string)<br/>    enabled      = optional(bool, true)<br/>    severity     = optional(number, 1)<br/><br/>    evaluation_frequency = optional(string, "PT5M")<br/>    window_duration      = optional(string, "PT30M")<br/><br/>    criteria = object({<br/>      query                   = string<br/>      threshold               = number<br/>      operator                = optional(string, "GreaterThan")<br/>      time_aggregation_method = optional(string, "Count")<br/>      metric_measure_column   = optional(string)<br/>      resource_id_column      = optional(string)<br/>      dimensions = optional(list(object({<br/>        name     = string<br/>        values   = list(string)<br/>        operator = optional(string, "Include")<br/>      })), [])<br/>      failing_periods = optional(object({<br/>        minimum_failing_periods_to_trigger_alert = number<br/>        number_of_evaluation_periods             = number<br/>      }))<br/>    })<br/><br/>    auto_mitigation_enabled           = optional(bool, false)<br/>    mute_actions_after_alert_duration = optional(string)<br/>    query_time_range_override         = optional(string)<br/>    skip_query_validation             = optional(bool, false)<br/>    target_resource_types             = optional(list(string), [])<br/>    workspace_alerts_storage_enabled  = optional(bool, false)<br/><br/>    action_group_ids  = optional(list(string), [])<br/>    email_subject     = optional(string)<br/>    custom_properties = optional(map(string), {})<br/><br/>    identity = optional(object({<br/>      type         = string<br/>      identity_ids = optional(list(string), [])<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | List of secrets (name and value) | `map(string)` | `{}` | no |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | SKU for the key vault - standard or premium | `string` | `"standard"` | no |
| <a name="input_soft_delete_retention_days"></a> [soft\_delete\_retention\_days](#input\_soft\_delete\_retention\_days) | Number of retention days for soft delete | `number` | `7` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The ID of the Subnet from which Private IP Addresses will be allocated for this Private Endpoint.<br/>    Changing this forces a new resource to be created. | `string` | `null` | no |
| <a name="input_subresource_names"></a> [subresource\_names](#input\_subresource\_names) | A list of subresource names which the Private Endpoint is able to connect to. subresource\_names corresponds to group\_id.<br/>    Possible values are detailed in the product documentation in the Subresources column.<br/>    https://docs.microsoft.com/azure/private-link/private-endpoint-overview#private-link-resource | `list(string)` | <pre>[<br/>  "vault"<br/>]</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to be associated with the resources | `map(string)` | `{}` | no |
| <a name="input_use_azure_region_abbr"></a> [use\_azure\_region\_abbr](#input\_use\_azure\_region\_abbr) | Use Azure region abbreviation in the resource name | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_policies_object_ids"></a> [access\_policies\_object\_ids](#output\_access\_policies\_object\_ids) | Object IDs of the Key Vault Access Policies |
| <a name="output_certificate_ids"></a> [certificate\_ids](#output\_certificate\_ids) | IDs of the certificates from the Key Vault in the reference module |
| <a name="output_key_ids"></a> [key\_ids](#output\_key\_ids) | IDs of the keys from the Key Vault in the reference module |
| <a name="output_key_vault_id"></a> [key\_vault\_id](#output\_key\_vault\_id) | ID of the Key Vault |
| <a name="output_key_vault_name"></a> [key\_vault\_name](#output\_key\_vault\_name) | Name of the Key Vault |
| <a name="output_private_endpoint_id"></a> [private\_endpoint\_id](#output\_private\_endpoint\_id) | ID of the Private Endpoint |
| <a name="output_resource_group_id"></a> [resource\_group\_id](#output\_resource\_group\_id) | ID of the Resource Group |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Name of the Resource Group |
| <a name="output_scheduled_query_alert_ids"></a> [scheduled\_query\_alert\_ids](#output\_scheduled\_query\_alert\_ids) | IDs of the scheduled query alerts created by the reference module |
| <a name="output_scheduled_query_alert_names"></a> [scheduled\_query\_alert\_names](#output\_scheduled\_query\_alert\_names) | Names of the scheduled query alerts created by the reference module |
| <a name="output_scheduled_query_alert_principal_ids"></a> [scheduled\_query\_alert\_principal\_ids](#output\_scheduled\_query\_alert\_principal\_ids) | Principal IDs of the scheduled query alerts' SystemAssigned identities, for granting them read access to the resources their queries read. Null for alerts with no identity, and empty for UserAssigned. |
| <a name="output_secret_ids"></a> [secret\_ids](#output\_secret\_ids) | IDs of the secrets from the Key Vault in the reference module |
| <a name="output_vault_uri"></a> [vault\_uri](#output\_vault\_uri) | URI of the Key Vault |
<!-- END_TF_DOCS -->

## Module Development

### Pre-Requisites

The following commands should be available on your system:

- `asdf` or `mise`
- `make`
- `python3` (for pre-commit)

Additionally, your `git` user and email must be configured. Run the `make configure` command from the root of the repository to ensure that you meet these requirements.

### Pre-Commit hooks

The [.pre-commit-config.yaml](.pre-commit-config.yaml) file defines certain `pre-commit` hooks that are relevant to Terraform and Golang, as well as some common linting tasks. These will be configured for you when you run `make configure`.

### Local Validation

You should validate the changes you make to any module locally, prior to pushing your changes in a branch to GitHub.

1. Ensure that you have run `make configure` successfully.

2. Ensure you are signed into the appropriate cloud provider (e.g. AWS or Azure) for the module under test in your current console session.

3. Run the Terraform and Golang linters with the following command:

```
make lint
```

4. Once you have satisfied the linters, the following command will build example infrastructure in your configured cloud, run the tests, and then tear down the infrastructure it created:

```
make test
```

The pre-commit validations, as well as the `make lint` and `make test` targets, will all be performed in CI. Running these validations locally prior to opening a PR helps ensure a smooth review and merge process.

### Review & Merge Process

Once your change has been tested locally and your branch pushed up, open a new Pull Request for your branch to the default (main) branch of this repository.

The title of your Pull Request will determine the version bump for this change, and the title must be in [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/#specification) format in order to merge. A breaking change will trigger a major version bump, a feature will trigger a minor version bump, and all other types will trigger a patch version bump.

Ensure your CI workflows are passing; seek approval from teammates and address any feedback; seek any explicit approvals required by the CODEOWNERS file. You may merge the PR as soon as all requirements are met, and a new release and tag will be automatically created for you.

### Automatic Updates

The shared configuration and workflow files in this repository are largely managed through the [launch-terraform-skeleton](https://github.com/launchbynttdata/launch-terraform-skeleton) repository. Outside of perhaps the `.gitignore` to account for specific files being generated by certain Terraform modules (e.g. Lambda functions), there should not be much cause to update these files on a per-repo basis, and making changes to them individually is discouraged.

If desired, you can check for and run these updates locally in a branch if you have the `copier` tool installed. Some example commands are included below:

```
# Check for updates, optionally checking prerelease versions
copier check-update [--prereleases]

# Run an update, using default answers if there are any. We use tasks, which requires --trust to be set.
copier update --defaults --trust [--prereleases]

# Recopy from the source, and --overwrite all templated files in the process
copier recopy --defaults --trust --overwrite [--prereleases]
```

Automatic updates will run through a scheduled workflow, and if the post-update tests are successful, the Pull Request created will automatically merge. Conflicts in the update or failures to test may leave a Pull Request outstanding, which needs to be addressed by a Launch Engineer.
