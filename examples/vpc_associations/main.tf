# --- examples/vpc_associations/main.tf ---

resource "aws_vpclattice_service_network" "service_network" {
  name      = "sn-vpc-associations"
  auth_type = "NONE"
}

module "vpclattice_vpc_associations" {
  source = "../.."

  service_network = {
    identifier = aws_vpclattice_service_network.service_network.id
  }

  vpc_associations = { for k, v in module.vpcs : k => {
    vpc_id = v.vpc_attributes.id
  } }
}

module "vpcs" {
  for_each = var.vpcs
  source   = "aws-ia/vpc/aws"
  version  = "4.2.1"

  name       = each.key
  cidr_block = each.value.cidr_block
  az_count   = each.value.number_azs

  subnets = {
    workload = { netmask = 28 }
  }
}
