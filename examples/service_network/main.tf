# --- examples/service_network/main.tf ---

# Example 1: VPC Lattice service network created without auth policy
module "vpclattice_service_network_without_policy" {
  source = "../.."

  service_network = {
    name                  = "service-network-without-policy"
    auth_type             = "NONE"
    access_log_cloudwatch = aws_cloudwatch_log_group.service_network_loggroup.arn
    access_log_s3         = aws_s3_bucket.service_network_logbucket.arn
    access_log_firehose   = aws_kinesis_firehose_delivery_stream.service_network_deliverystream.arn
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

# ---------- SUPPORT RESOURCES ----------
# Generate random string (for resources' names)
resource "random_string" "random" {
  length  = 8
  special = false
  upper   = false
}

# S3 Bucket
resource "aws_s3_bucket" "service_network_logbucket" {
  bucket        = "sn-logbucket-${random_string.random.result}"
  force_destroy = true
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "service_network_loggroup" {
  name              = "sn_loggroup-${random_string.random.result}"
  retention_in_days = 0
}

# Firehose Delivery Stream
resource "aws_kinesis_firehose_delivery_stream" "service_network_deliverystream" {
  name        = "sn-loggroup-firehose-${random_string.random.result}"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose_role.arn
    bucket_arn = aws_s3_bucket.service_network_logbucket.arn
  }
}

# IAM Role (for Firehose Delivery Stream)
data "aws_iam_policy_document" "firehose_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "firehose_role" {
  name               = "firehose_test_role"
  assume_role_policy = data.aws_iam_policy_document.firehose_assume_role.json
}

# VPCs
module "vpcs" {
  for_each = var.vpcs
  source   = "aws-ia/vpc/aws"
  version  = "4.4.4"

  name       = each.key
  cidr_block = each.value.cidr_block
  az_count   = each.value.number_azs

  subnets = {
    workload = { netmask = 28 }
  }
}