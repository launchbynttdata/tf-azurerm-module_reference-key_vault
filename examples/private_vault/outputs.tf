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


output "resource_group_id" {
  value = module.key_vault.resource_group_id
}

output "resource_group_name" {
  value = module.key_vault.resource_group_name
}

output "key_vault_id" {
  value = module.key_vault.key_vault_id
}

output "vault_uri" {
  value = module.key_vault.vault_uri
}

output "access_policies_object_ids" {
  value = module.key_vault.access_policies_object_ids
}

output "key_vault_name" {
  value = module.key_vault.key_vault_name
}

output "certificate_ids" {
  description = "IDs of the certificates from the Key Vault in the reference module"
  value       = module.key_vault.certificate_ids
}

output "secret_ids" {
  description = "IDs of the secrets from the Key Vault in the reference module"
  value       = module.key_vault.secret_ids
}

output "key_ids" {
  description = "IDs of the keys from the Key Vault in the reference module"
  value       = module.key_vault.key_ids
}

output "scheduled_query_alert_ids" {
  description = "IDs of the scheduled query alerts created by the reference module"
  value       = module.key_vault.scheduled_query_alert_ids
}

output "scheduled_query_alert_names" {
  description = "Names of the scheduled query alerts created by the reference module"
  value       = module.key_vault.scheduled_query_alert_names
}

output "private_endpoint_id" {
  description = "ID of the private endpoint, or an empty string when public network access is enabled"
  value       = module.key_vault.private_endpoint_id
}

output "action_group_id" {
  description = "ID of the action group the reference module creates"
  value       = module.key_vault.action_group_id
}

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace the reference module creates"
  value       = module.key_vault.log_analytics_workspace_id
}
