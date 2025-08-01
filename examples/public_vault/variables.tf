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

variable "certificates" {
  description = "List of certificates to be imported. If `filepath` is specified then the pfx files should be present in the root of the module (path.root). If `content` is specified then the content of the certificate should be provided in base 64 encoded format. Only one of them should be provided."
  type = map(object({
    contents = optional(string)
    filepath = optional(string)
    password = string
  }))
  default = {}
}

variable "certificate_issuers" {
  description = "List of certificate issuers to be created"
  type = map(object({
    provider_name = string
    org_id        = string
    account_id    = string
    password      = string

    admins = optional(list(object({
      email_address = string
      first_name    = optional(string)
      last_name     = optional(string)
      phone         = optional(string)
    })))
  }))
  default = {}
}

variable "generated_certificates" {
  description = "List of certificates to be generated using an issuer."
  type = map(object({
    issuer_name = string

    key_properties = optional(object({
      exportable = bool
      reuse_key  = bool
      key_type   = string

      key_size = optional(number, 2048)
      curve    = optional(string, "P-256")
    }))

    lifetime_action = optional(object({
      action = object({
        action_type = string
      })
      trigger = object({
        lifetime_percentage = optional(number)
        days_before_expiry  = optional(number)
      })
    }))

    secret_properties = optional(object({
      content_type = string
    }))

    x509_certificate_properties = optional(object({
      key_usage          = list(string)
      extended_key_usage = optional(list(string))
      subject            = string
      validity_in_months = number
      subject_alternative_names = optional(object({
        dns_names = optional(list(string))
        emails    = optional(list(string))
        upns      = optional(list(string))
      }))
    }))
  }))
  default = {}
}

variable "secrets" {
  description = "List of secrets (name and value)"
  type        = map(string)
  default     = {}
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
    vnet = {
      name       = "vnet"
      max_length = 60
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
    role_definition_name = string
    principal_id         = string
    principal_type       = string
  }))
  default = {}
}

variable "role_assignment_type" {
  description = "The type of role assignment to be created"
  type        = string
  default     = "ServicePrincipal"
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

################################################
# Variables related to private endpoint
################################################

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

########################################
# Variables related to virtual network
########################################

variable "use_for_each" {
  type        = bool
  description = "Use `for_each` instead of `count` to create multiple resource instances."
  nullable    = false
}

variable "address_space" {
  type        = list(string)
  description = "The address space that is used by the virtual network."
}

variable "bgp_community" {
  type        = string
  default     = null
  description = "(Optional) The BGP community attribute in format `<as-number>:<community-value>`."
}

variable "ddos_protection_plan" {
  type = object({
    enable = bool
    id     = string
  })
  default     = null
  description = "The set of DDoS protection plan configuration"
}

# If no values specified, this defaults to Azure DNS
variable "dns_servers" {
  type        = list(string)
  default     = []
  description = "The DNS servers to be used with vNet."
}

variable "nsg_ids" {
  type = map(string)
  default = {
  }
  description = "A map of subnet name to Network Security Group IDs"
}

variable "route_tables_ids" {
  type        = map(string)
  default     = {}
  description = "A map of subnet name to Route table ids"
}

variable "subnet_delegation" {
  type        = map(map(any))
  default     = {}
  description = "A map of subnet name to delegation block on the subnet"
}

variable "subnet_private_endpoint_network_policies_enabled" {
  type        = map(string)
  default     = {}
  description = "A map of subnet name to enable/disable private link service network policies on the subnet."
}

variable "subnet_names" {
  type        = list(string)
  description = "A list of public subnets inside the vNet."
}

variable "subnet_prefixes" {
  type        = list(string)
  description = "The address prefix to use for the subnet."
}

variable "subnet_service_endpoints" {
  type        = map(any)
  default     = {}
  description = "A map of subnet name to service endpoints to add to the subnet."
}

################################################
# Tags to be associated with all child modules
################################################
variable "tags" {
  description = "A map of tags to be associated with the resources"
  type        = map(string)
  default     = {}
}
