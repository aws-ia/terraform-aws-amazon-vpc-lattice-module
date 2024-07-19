# --- examples/ram_share/variables.tf ---

variable "aws_region" {
  type        = string
  description = "AWS Region to use."
  default     = "eu-west-1"
}

variable "aws_account_id" {
  type        = string
  description = "AWS Account ID - to share AWS RAM share."
}