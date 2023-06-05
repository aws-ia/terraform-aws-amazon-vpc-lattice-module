# --- examples/service_association/outputs.tf ---

output "services" {
  description = "VPC Lattice Service ID."
  value = { for k, v in module.services.services : k => {
    id                  = v.attributes.id
    domain_name         = v.attributes.dns_entry[0].domain_name
    service_association = v.service_network_association.id
  } }
}