# --- examples/dns_configuration/variables.tf ---

variable "aws_region" {
  type        = string
  description = "AWS Region to use."
  default     = "eu-west-1"
}