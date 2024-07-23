# --- root/variables.tf ---

variable "service_network" {
  type        = any
  description = <<-EOF
    Amazon VPC Lattice Service Network information. You can either create a new Service Network or reference a current one (to associate Services or VPCs). Setting the `name` attribute will create a **new** service network, while using the attribute `identifier` will reference an **existing** service network.
    More information about the format of this variable can be found in the "Usage - Service Network" section of the README.
EOF

  default = {}

  validation {
    error_message = "Invalid key in any of the definitions for var.service_network. Valid options include: \"name\", \"auth_type\", \"auth_policy\", \"identifier\", \"identifier\"."
    condition = length(setsubtract(keys(try(var.service_network, {})), [
      "name",
      "auth_type",
      "auth_policy",
      "identifier"
    ])) == 0
  }

  validation {
    error_message = "You should define either the `name` of a new Service Network or its `identifier`, not both attributes."
    condition     = length(setintersection(keys(try(var.service_network, {})), ["name", "identifier"])) != 2
  }
}

variable "vpc_associations" {
  type = map(object({
    vpc_id             = optional(string)
    security_group_ids = optional(list(string))
  }))
  description = <<-EOF
    VPC Lattice VPC associations. You can define 1 or more VPC associations using this module.
    More information about the format of this variable can be found in the "Usage - VPC association" section of the README.
EOF

  default = {}
}

variable "services" {
  type        = any
  description = <<-EOF
  Definition of the VPC Lattice Services to create. You can use this module to either create only Lattice services (not associated with any service network), or associated with a service network (if you create one or provide an identifier). You can define 1 or more Service using this module.
  More information about the format of this variable can be found in the "Usage - Services" section of the README.
EOF

  default = {}

  validation {
    error_message = "Invalid key in any of the definitions for var.services. Valid options include: \"identifier\", \"name\", \"auth_type\", \"auth_policy\", \"certificate_arn\", \"custom_domain_name\", \"listeners\"."
    condition = alltrue([
      for service in try(var.services, {}) : length(setsubtract(keys(try(service, {})), [
        "identifier",
        "name",
        "auth_type",
        "auth_policy",
        "certificate_arn",
        "custom_domain_name",
        "listeners"
      ])) == 0
    ])
  }
}

variable "target_groups" {
  type        = any
  description = <<-EOF
  Definitions of the Target Groups to create. You can define 1 or more Target Groups using this module.
  More information about the format of this variable can be found in the "Usage - Target Groups" section of the README.
EOF

  default = {}

  validation {
    error_message = "Invalid key in any of the definitions for var.target_groups. Valid options include: \"name\", \"type\", \"config\", \"health_check\", \"targets\"."
    condition = alltrue([
      for tg in try(var.target_groups, {}) : length(setsubtract(keys(try(tg, {})), [
        "name",
        "type",
        "config",
        "health_check",
        "targets"
      ])) == 0
    ])
  }
}

variable "ram_share" {
  type        = any
  description = <<-EOF
  Configuration of the resources to share using AWS Resource Access Manager (RAM). VPC Lattice service networks and services can be shared using RAM.
  More information about the format of this variable can be found in the "Usage - AWS RAM share" section of the README.
EOF

  default = {}

  validation {
    error_message = "Invalid key in any of the definitions for var.ram_share. Valid options include: \"resource_share_arn\", \"resource_share_name\", \"allow_external_principals\", \"principals\", \"share_service_network\", \"share_services\"."
    condition = length(setsubtract(keys(var.ram_share), [
      "resource_share_arn",
      "resource_share_name",
      "allow_external_principals",
      "principals",
      "share_service_network",
      "share_services"
    ])) == 0
  }
}

variable "tags" {
  description = "Tags to apply to all the resources created in this module."
  type        = map(string)

  default = {}
}
