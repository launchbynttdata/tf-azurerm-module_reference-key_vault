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
