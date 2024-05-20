# --- modules/targets/variables.tf ---

variable "target_type" {
  type        = string
  description = "Target type."
}

variable "target_group_identifier" {
  type        = string
  description = "Target group identifier."
}

variable "targets" {
  type        = map(any)
  description = "Targets information - for the target group attachment."
}