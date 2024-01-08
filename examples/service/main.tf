# --- examples/service/main.tf ---

# VPC Lattice Service - with two listeners and two three groups
module "myservice" {
  source = "../.."

  services = {
    myservice = {
      name      = "myservice"
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

      listeners = {
        # HTTP listener
        http_listener = {
          name                         = "httplistener"
          port                         = 80
          protocol                     = "HTTP"
          default_action_fixedresponse = { status_code = 404 }
          rules = {
            lambdapath = {
              priority   = 10
              path_match = { prefix = "/lambda" }
              action_forward = {
                target_groups = {
                  lambdatargethttp = { weight = 100 }
                }
              }
            }
            instanceheader = {
              priority = 20
              header_matches = {
                name  = "target"
                exact = "instance"
              }
              action_fixedresponse = { status_code = 404 }
            }
          }
        }
        # HTTPS listener
        https_listener = {
          name     = "httpslistener"
          port     = 443
          protocol = "HTTPS"
          default_action_forward = {
            target_groups = {
              instancetarget    = { weight = 50 }
              lambdatargethttps = { weight = 50 }
            }
          }
        }
      }
    }
  }

  target_groups = {
    instancetarget = {
      name = "instance-target"
      type = "INSTANCE"
      config = {
        port           = 80
        protocol       = "HTTP"
        vpc_identifier = module.vpc.vpc_attributes.id
      }
      health_check = {
        enabled = false
      }
    }
    lambdatargethttp  = { type = "LAMBDA" }
    lambdatargethttps = { type = "LAMBDA" }
  }
}

module "vpc" {
  source  = "aws-ia/vpc/aws"
  version = "4.4.1"

  name       = "provider-vcp"
  cidr_block = "10.0.0.0/24"
  az_count   = 2

  subnets = {
    workload = { netmask = 28 }
  }
}