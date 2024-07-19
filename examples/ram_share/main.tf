# --- examples/ram_share/main.tf ---

# Obtaining the AWS Account ID to share the resources with. 
# If you are testing outside the module automation, either change this value with an AWS Account you own, or create a Parameter with this value
data "aws_ssm_parameter" "account_id" {
  name = "account_id_share"
}

module "vpclattice_service_network_share" {
  source = "../.."

  service_network = {
    name      = "service-network"
    auth_type = "NONE"
  }

  ram_share = {
    resource_share_name       = "service-network-resource-share"
    allow_external_principals = true
    principals                = [data.aws_ssm_parameter.account_id.value]
  }
}

module "vpclattice_services_share" {
  source = "../.."

  services = {
    service1 = {
      name      = "service1"
      auth_type = "NONE"
    }
    service2 = {
      name      = "service2"
      auth_type = "NONE"
    }
    service3 = {
      name      = "service3"
      auth_type = "NONE"
    }
  }

  ram_share = {
    resource_share_arn = aws_ram_resource_share.vpclattice_resource_share.arn
    principals         = [data.aws_ssm_parameter.account_id.value]
    share_services     = ["service1", "service2"]
  }
}

resource "aws_ram_resource_share" "vpclattice_resource_share" {
  name                      = "services-resource-share"
  allow_external_principals = true
}

