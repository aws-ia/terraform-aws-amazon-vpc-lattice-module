# --- examples/service_association/main.tf ---

# VPC Lattice Service Network - using VPC Lattice module
module "service_network" {
  source = "../.."

  service_network = {
    name = "sn-service-associations"
  }
}

# VPC Lattice Service - and association with Service Network
module "services" {
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