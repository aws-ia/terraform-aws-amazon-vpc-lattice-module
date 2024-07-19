# --- examples/ram_share/main.tf ---

module "vpclattice_service_network_share" {
  source = "../.."

  service_network = {
    name      = "service-network"
    auth_type = "NONE"
  }

  ram_share = {
    resource_share_name       = "service-network-resource-share"
    allow_external_principals = true
    principals                = [var.aws_account_id]
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
    principals         = [var.aws_account_id]
    share_services     = ["service1", "service2"]
    example            = true
  }
}

resource "aws_ram_resource_share" "vpclattice_resource_share" {
  name                      = "services-resource-share"
  allow_external_principals = true
}

