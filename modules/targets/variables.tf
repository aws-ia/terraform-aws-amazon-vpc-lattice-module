# --- modules/targets/variables.tf ---

variable "target_group_identifier" {
  type        = string
  description = "Target group identifier."
}

variable "targets" {
  type        = map(any)
  description = "Targets information - for the target group attachment."
}