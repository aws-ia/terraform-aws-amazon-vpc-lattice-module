# --- examples/service/main.tf ---

# EXAMPLE 1: VPC Lattice service configured with a custom domain name and no auth policy
module "service_customdomainname_noauth" {
  source = "../.."

  services = {
    service1 = {
      name                  = "service-noauth"
      auth_type             = "NONE"
      custom_domain_name    = "example.domain.net"
      access_log_cloudwatch = aws_cloudwatch_log_group.service_network_loggroup.arn
      access_log_s3         = aws_s3_bucket.service_network_logbucket.arn
      access_log_firehose   = aws_kinesis_firehose_delivery_stream.service_network_deliverystream.arn
    }
  }
}

# EXAMPLE 2: VPC Lattice service configured with auth type "AWS_IAM"
module "service_auth" {
  source = "../.."

  services = {
    service1 = {
      name      = "service-auth"
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
}

# EXAMPLE 3: VPC Lattice services associated to a service network
module "service_network" {
  source = "../.."

  service_network = {
    name = "sn-service-associations"
  }
}

module "service_associations" {
  source = "../.."

  service_network = {
    identifier = module.service_network.service_network.id
  }

  services = {
    service1 = {
      name = "service1"
    }
    service2 = {
      name = "service2"
    }
  }
}

# EXAMPLE 4: VPC Lattice service with HTTP listener (2 listener rules)
# - Default action fixed-response (404)
# - Rule1 (priority 10) - If prefix /lambda, sends all the traffic to target1
# - Rule2 (priority 20) - If header "target = instance", sends a fixed-response (404)
module "service_httplistener" {
  source = "../.."

  services = {
    myservice = {
      name = "service-httplistener"
      listeners = {
        http_listener = {
          name                         = "httplistener"
          port                         = 80
          protocol                     = "HTTP"
          default_action_fixedresponse = { status_code = 404 }
          rules = {
            rule1 = {
              priority   = 10
              path_match = { prefix = "/lambda" }
              action_forward = {
                target_groups = {
                  target1 = { weight = 100 }
                }
              }
            }
            rule2 = {
              priority = 20
              header_matches = {
                name  = "target"
                exact = "instance"
              }
              action_fixedresponse = { status_code = 404 }
            }
          }
        }
      }
    }
  }

  target_groups = {
    target1 = { type = "LAMBDA" }
  }
}

# EXAMPLE 5: VPC Lattice with HTTPS listener (forward default action)
module "service_httpslistener" {
  source = "../.."

  services = {
    myservice = {
      name      = "service-httpslistener"
      auth_type = "NONE"

      listeners = {
        https_listener = {
          name     = "httpslistener"
          port     = 443
          protocol = "HTTPS"
          default_action_forward = {
            target_groups = {
              target2 = { weight = 50 }
              target3 = { weight = 50 }
            }
          }
        }
      }
    }
  }

  target_groups = {
    target2 = { type = "LAMBDA" }
    target3 = { type = "LAMBDA" }
  }
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