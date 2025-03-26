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
  description = "ID of the Resource Group"
  value       = module.resource_group.id
}

output "resource_group_name" {
  description = "Name of the Resource Group"
  value       = module.resource_group.name
}

output "key_vault_id" {
  description = "ID of the Key Vault"
  value       = module.key_vault.key_vault_id
}

output "vault_uri" {
  description = "URI of the Key Vault"
  value       = module.key_vault.vault_uri
}

output "access_policies_object_ids" {
  description = "Object IDs of the Key Vault Access Policies"
  value       = module.key_vault.access_policies_object_ids
}

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = module.key_vault.key_vault_name
}

output "private_dns_zone_id" {
  description = "ID of the Private DNS Zone"
  value       = try(module.private_dns_zone[0].id, "")
}

output "private_endpoint_id" {
  description = "ID of the Private Endpoint"
  value       = try(module.private_endpoint[0].id, "")
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
