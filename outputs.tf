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
  value = module.resource_group.id
}

output "resource_group_name" {
  value = module.resource_group.name
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
