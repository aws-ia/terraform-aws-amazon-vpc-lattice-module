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

module "dns_resolution_example1" {
  source = "../.."

  dns_configuration = {
    hosted_zone_id = aws_route53_zone.global_private_hosted_zone.id
  }

  services = {
    # EXAMPLE 1: VPC Lattice service created by the module and Alias record created in the "global" PHZ
    service1 = {
      name               = "service1"
      auth_type          = "NONE"
      custom_domain_name = "service1.global.com"
    }

    # EXAMPLE 2: VPC Lattice service created outside the module and Alias record created in the "global" PHZ
    service2 = {
      identifier = aws_vpclattice_service.service2.arn
    }

    # EXAMPLE 3: VPC Lattice service created by the module and Alias record created in the "specific" PHZ
    service3 = {
      name               = "service3"
      auth_type          = "NONE"
      custom_domain_name = "service3.specific.com"
      hosted_zone_id     = aws_route53_zone.specific_private_hosted_zone.id
    }

    # EXAMPLE 4: VPC Lattice service created outside the module and Alias record created in the "specific" PHZ
    service4 = {
      identifier     = aws_vpclattice_service.service4.arn
      hosted_zone_id = aws_route53_zone.specific_private_hosted_zone.id
    }
  }
}

resource "aws_vpclattice_service" "service2" {
  name               = "service2"
  auth_type          = "NONE"
  custom_domain_name = "service2.global.com"
}

resource "aws_vpclattice_service" "service4" {
  name               = "service4"
  auth_type          = "NONE"
  custom_domain_name = "service4.global.com"
}

module "dns_resolution_example3" {
  source = "../.."

  services = {
    # EXAMPLE 5: VPC Lattice service created by the module (no Alias record created)
    service5 = {
      name      = "service7"
      auth_type = "NONE"
    }

    # EXAMPLE 5: VPC Lattice service created outside the module and Alias record created in the "specific" PHZ
    service6 = {
      identifier     = aws_vpclattice_service.service6.arn
      hosted_zone_id = aws_route53_zone.specific_private_hosted_zone.id
    }
  }
}

resource "aws_vpclattice_service" "service6" {
  name               = "service8"
  auth_type          = "NONE"
  custom_domain_name = "service6.specific.com"
}