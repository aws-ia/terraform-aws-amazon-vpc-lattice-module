# --- examples/vpc_associations/variables.tf ---

variable "aws_region" {
  type        = string
  description = "AWS Region to use."
  default     = "eu-west-1"
}

variable "vpcs" {
  type        = map(any)
  description = "VPCs to create."
  default = {
    vpc1 = {
      cidr_block = "10.0.0.0/24"
      number_azs = 2
    }
    vpc2 = {
      cidr_block = "10.0.1.0/24"
      number_azs = 2
    }
  }
}
