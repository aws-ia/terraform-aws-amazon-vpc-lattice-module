# --- modules/listener_rules/variables.tf ---

variable "listener_rules" {
  type        = any
  description = "Listener rules to create."
}

variable "listener_identifier" {
  type        = string
  description = "VPC Lattice Listener identifier."
}

variable "service_identifier" {
  type        = string
  description = "VPC Lattice Service identifier."
}

variable "target_groups" {
  type        = map(string)
  description = "VPC Lattice target group identifiers."
}

variable "tags" {
  type        = map(string)
  description = "Tags to configure in the resources created."
}