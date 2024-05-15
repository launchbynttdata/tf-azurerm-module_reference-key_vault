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

#########################################
# Variables related to Resource Group
#########################################

variable "location" {
  description = "Location of the resource group and other services in this module."
  type        = string
}

#########################################
# Variables related to Key Vault
#########################################

variable "enabled_for_deployment" {
  description = "If Azure VM is permitted to retrieve secrets"
  type        = bool
  default     = false
}

variable "enabled_for_template_deployment" {
  description = "If Azure RM is permitted to retrieve secrets"
  type        = bool
  default     = false
}

variable "soft_delete_retention_days" {
  description = "Number of retention days for soft delete"
  type        = number
  default     = 7
}

variable "purge_protection_enabled" {
  description = "If purge_protection is enabled"
  type        = bool
  default     = false
}

variable "sku_name" {
  description = "SKU for the key vault - standard or premium"
  type        = string
  default     = "standard"
}

variable "access_policies" {
  description = "Additional Access policies for the vault except the current user which are added by default"
  type = map(object({
    object_id               = string
    tenant_id               = string
    key_permissions         = list(string)
    certificate_permissions = list(string)
    secret_permissions      = list(string)
    storage_permissions     = list(string)
  }))

  default = {}
}

variable "enable_rbac_authorization" {
  description = "Enable RBAC authorization for the key vault"
  type        = bool
  default     = false
}

variable "network_acls" {
  description = "Network ACLs for the key vault"
  type = object({
    bypass                     = string
    default_action             = string
    ip_rules                   = optional(list(string))
    virtual_network_subnet_ids = optional(list(string))
  })

  default = {
    bypass                     = "AzureServices"
    default_action             = "Allow"
    ip_rules                   = []
    virtual_network_subnet_ids = []
  }
}

variable "public_network_access_enabled" {
  description = " (Optional) Whether public network access is allowed for this Key Vault. Defaults to true."
  type        = bool
  default     = true
}

#########################################
# Variables related to Resource Names
#########################################
variable "resource_names_map" {
  description = "A map of key to resource_name that will be used by tf-launch-module_library-resource_name to generate resource names"
  type = map(object({
    name       = string
    max_length = optional(number, 60)
  }))

  default = {
    key_vault = {
      name       = "kv"
      max_length = 24
    }
    resource_group = {
      name       = "rg"
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
  }
}
variable "environment" {
  description = "Environment in which the resource should be provisioned like dev, qa, prod etc."
  type        = string
}

variable "environment_number" {
  description = "The environment count for the respective environment. Defaults to 000. Increments in value of 1"
  type        = string
  default     = "000"
}

variable "resource_number" {
  description = "The resource count for the respective resource. Defaults to 000. Increments in value of 1"
  type        = string
  default     = "000"
}

variable "logical_product_family" {
  type        = string
  description = <<EOF
    (Required) Name of the product family for which the resource is created.
    Example: org_name, department_name.
  EOF
  nullable    = false

  validation {
    condition     = can(regex("^[_\\-A-Za-z0-9]+$", var.logical_product_family))
    error_message = "The variable must contain letters, numbers, -, _, and .."
  }
}

variable "logical_product_service" {
  type        = string
  description = <<EOF
    (Required) Name of the product service for which the resource is created.
    For example, backend, frontend, middleware etc.
  EOF
  nullable    = false

  validation {
    condition     = can(regex("^[_\\-A-Za-z0-9]+$", var.logical_product_service))
    error_message = "The variable must contain letters, numbers, -, _, and .."
  }
}

variable "use_azure_region_abbr" {
  type        = bool
  description = "Use Azure region abbreviation in the resource name"
  default     = true
}

#########################################
# Variables related to Role assignment
#########################################

variable "role_assignments" {
  description = "A map of role assignments to be created"
  type = map(object({
    name                 = optional(string)
    scope                = optional(string)
    role_definition_name = string
    principal_id         = optional(string)
  }))
  default = {}
}

###########################################
# Variables related to private DNS zone
###########################################

variable "zone_name" {
  type        = string
  description = "Name of the private dns zone. For public cloud, the default value is `privatelink.vaultcore.azure.net` and for sovereign clouds, the default value is `privatelink.vaultcore.usgovcloudapi.net`"
  default     = "privatelink.vaultcore.azure.net"
  validation {
    condition     = contains(["privatelink.vaultcore.azure.net", "privatelink.vaultcore.usgovcloudapi.net"], var.zone_name)
    error_message = "The zone_name must be either 'privatelink.vaultcore.azure.net' or 'privatelink.vaultcore.usgovcloudapi.net'."
  }
}

variable "soa_record" {
  type = object({
    email        = string
    expire_time  = number
    minimum_ttl  = number
    refresh_time = number
    retry_time   = number
    ttl          = number
    tags         = map(string)
  })
  default = null
}

################################################
# Variables related to private DNS zone link
################################################

variable "additional_vnet_links" {
  description = "The list of Virtual Network ids that should be linked to the DNS Zone. Changing this forces a new resource to be created."
  type        = map(string)
  default     = {}
}

################################################
# Variables related to private endpoint
################################################

variable "subnet_id" {
  description = <<EOT
    The ID of the Subnet from which Private IP Addresses will be allocated for this Private Endpoint.
    Changing this forces a new resource to be created.
  EOT
  type        = string
}

variable "private_dns_zone_group_name" {
  description = "Specifies the Name of the Private DNS Zone Group."
  type        = string
  default     = ""
}

variable "is_manual_connection" {
  description = <<EOT
    Does the Private Endpoint require Manual Approval from the remote resource owner? Changing this forces a new resource
    to be created.
  EOT
  type        = bool
  default     = false
}

variable "subresource_names" {
  description = <<EOT
    A list of subresource names which the Private Endpoint is able to connect to. subresource_names corresponds to group_id.
    Possible values are detailed in the product documentation in the Subresources column.
    https://docs.microsoft.com/azure/private-link/private-endpoint-overview#private-link-resource
  EOT
  type        = list(string)
  default     = ["vault"]
}

variable "request_message" {
  description = <<EOT
    A message passed to the owner of the remote resource when the private endpoint attempts to establish the connection
    to the remote resource. The request message can be a maximum of 140 characters in length.
    Only valid if `is_manual_connection=true`
  EOT
  type        = string
  default     = ""
}

################################################
# Tags to be associated with all child modules
################################################
variable "tags" {
  description = "A map of tags to be associated with the resources"
  type        = map(string)
  default     = {}
}
