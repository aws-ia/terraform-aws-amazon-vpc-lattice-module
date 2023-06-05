# --- examples/service_network/variables.tf ---

variable "aws_region" {
  type        = string
  description = "AWS Region to use."
  default     = "eu-west-1"
}