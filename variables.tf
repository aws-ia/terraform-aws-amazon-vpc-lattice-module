# --- root/variables.tf ---

variable "service_network" {
  type        = any
  description = <<-EOF
    Amazon VPC Lattice service network information. You can either create a new service network or reference a current one (to associate VPC Lattice services or VPCs). Setting the `name` attribute will create a **new** service network, while using the attribute `identifier` will reference an **existing** service network.
    More information about the format of this variable can be found in the "Usage - VPC Lattice service network" section of the README.
EOF

  default = {}

  validation {
    error_message = "Invalid key in any of the definitions for var.service_network. Valid options include: \"name\", \"auth_type\", \"auth_policy\", \"identifier\", \"access_log_cloudwatch\", \"access_log_s3\", \"access_log_firehose\"."
    condition = length(setsubtract(keys(try(var.service_network, {})), [
      "name",
      "auth_type",
      "auth_policy",
      "identifier",
      "access_log_cloudwatch",
      "access_log_s3",
      "access_log_firehose"
    ])) == 0
  }

  validation {
    error_message = "You should define either the `name` of a new VPC Lattice service network or its `identifier`, not both attributes."
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
  More information about the format of this variable can be found in the "Usage - VPC Lattice service" section of the README.
EOF

  default = {}

  validation {
    error_message = "Invalid key in any of the definitions for var.services. Valid options include: \"identifier\", \"name\", \"auth_type\", \"auth_policy\", \"certificate_arn\", \"custom_domain_name\", \"listeners\", \"hosted_zone_id\", \"access_log_cloudwatch\", \"access_log_s3\", and \"access_log_firehose\"."
    condition = alltrue([
      for service in try(var.services, {}) : length(setsubtract(keys(try(service, {})), [
        "identifier",
        "name",
        "auth_type",
        "auth_policy",
        "certificate_arn",
        "custom_domain_name",
        "listeners",
        "hosted_zone_id",
        "access_log_cloudwatch",
        "access_log_s3",
        "access_log_firehose"
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
  More information about the format of this variable can be found in the "Sharing VPC Lattice resources" section of the README.
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

variable "dns_configuration" {
  type        = map(string)
  description = <<-EOF
  Amazon Route 53 DNS configuration. For VPC Lattice services with custom domain name configured, you can indicate the Hosted Zone ID to create the corresponding Alias record (IPv4 and IPv6) pointing to the VPC Lattice-generated domain name.
  You can override the Hosted Zone to configure the Alias record by configuring the `hosted_zone_id` attribute under each service definition (`var.services`). 
  This configuration is only supported if both the VPC Lattice service and the Route 53 Hosted Zone are in the same account. More information about the variable format and multi-Account support can be found in the "Amazon Route 53 DNS configuration" section of the README.
EOF
  default     = {}

  validation {
    error_message = "Invalid key in any of the definitions for var.dns_configuration. Valid options include: \"hosted_zone_id\"."
    condition = length(setsubtract(keys(var.dns_configuration), [
      "hosted_zone_id"
    ])) == 0
  }
}

variable "tags" {
  description = "Tags to apply to all the resources created in this module."
  type        = map(string)

  default = {}
}
