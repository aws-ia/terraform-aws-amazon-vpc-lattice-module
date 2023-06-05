# --- modules/listeners/variables.tf ---

variable "listener_information" {
  type        = any
  description = "Information about the VPC Lattice Listener to create."
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