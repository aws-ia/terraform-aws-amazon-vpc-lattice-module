# --- examples/dns_configuration/main.tf ---

# Private Hosted Zones
resource "aws_route53_zone" "global_private_hosted_zone" {
  name = "global.com"

  vpc {
    vpc_id = aws_vpc.vpc.id
  }
}

resource "aws_route53_zone" "specific_private_hosted_zone" {
  name = "specific.com"

  vpc {
    vpc_id = aws_vpc.vpc.id
  }
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/24"
}

# VPC LATTICE MODULE EXAMPLE 1: Global Private Hosted Zone defined
module "dns_resolution_example1" {
  source = "../.."

  dns_configuration = {
    private_hosted_zone_id = aws_route53_zone.global_private_hosted_zone.id
  }

  services = {
    service1 = {
      name               = "service1"
      auth_type          = "NONE"
      custom_domain_name = "service1.global.com"
    }

    service2 = {
      name               = "service2"
      auth_type          = "NONE"
      custom_domain_name = "service2.global.com"
    }

    service3 = {
      identifier = aws_vpclattice_service.service3.arn
    }
  }
}

resource "aws_vpclattice_service" "service3" {
  name               = "service3"
  auth_type          = "NONE"
  custom_domain_name = "service3.global.com"
}

# VPC LATTICE MODULE EXAMPLE 2: Global Private Hosted Zone defined and specific secondary PHZ in 'service5'
module "dns_resolution_example2" {
  source = "../.."

  dns_configuration = {
    private_hosted_zone_id = aws_route53_zone.global_private_hosted_zone.id
  }

  services = {
    service4 = {
      name               = "service4"
      auth_type          = "NONE"
      custom_domain_name = "service4.global.com"
    }

    service5 = {
      name                   = "service5"
      auth_type              = "NONE"
      custom_domain_name     = "service5.specific.com"
      private_hosted_zone_id = aws_route53_zone.specific_private_hosted_zone.id
    }

    service6 = {
      identifier = aws_vpclattice_service.service6.arn
    }
  }
}

resource "aws_vpclattice_service" "service6" {
  name               = "service6"
  auth_type          = "NONE"
  custom_domain_name = "service6.global.com"
}

# VPC LATTICE MODULE EXAMPLE 2: Only specific secondary PHZ in 'service8'
module "dns_resolution_example3" {
  source = "../.."

  services = {
    service7 = {
      name      = "service7"
      auth_type = "NONE"
    }

    service8 = {
      identifier             = aws_vpclattice_service.service8.arn
      private_hosted_zone_id = aws_route53_zone.specific_private_hosted_zone.id
    }
  }
}

resource "aws_vpclattice_service" "service8" {
  name               = "service8"
  auth_type          = "NONE"
  custom_domain_name = "service8.specific.com"
}

