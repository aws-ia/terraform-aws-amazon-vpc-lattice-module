# --- examples/service_network/main.tf ---

# Example 1: VPC Lattice service network created without auth policy
module "vpclattice_service_network_without_policy" {
  source = "../.."

  service_network = {
    name      = "service-network-without-policy"
    auth_type = "NONE"
  }
}

# Example 2: VPC Lattice service network created with auth policy
module "vpclattice_service_network_with_policy" {
  source = "../.."

  service_network = {
    name      = "service-network-with-policy"
    auth_type = "AWS_IAM"
    auth_policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action    = "*"
          Effect    = "Allow"
          Principal = "*"
          Resource  = "*"
          Condition = {
            StringNotEqualsIgnoreCase = {
              "aws:PrincipalType" = "anonymous"
            }
          }
        }
      ]
    })
  }
}

# Example 3: VPC Lattice service network reference (created outside the module)
resource "aws_vpclattice_service_network" "external_service_network" {
  name      = "external-service-network"
  auth_type = "NONE"
}

module "vpclattice_service_network_referenced" {
  source = "../.."

  service_network = {
    identifier = aws_vpclattice_service_network.external_service_network.id
  }
}

# Example 4: VPC Lattice service network VPC association
module "vpclattice_vpc_associations" {
  source = "../.."

  service_network = {
    identifier = aws_vpclattice_service_network.external_service_network.id
  }

  vpc_associations = { for k, v in module.vpcs : k => {
    vpc_id = v.vpc_attributes.id
  } }
}

module "vpcs" {
  for_each = var.vpcs
  source   = "aws-ia/vpc/aws"
  version  = "4.4.1"

  name       = each.key
  cidr_block = each.value.cidr_block
  az_count   = each.value.number_azs

  subnets = {
    workload = { netmask = 28 }
  }
}