# --- examples/service/outputs.tf ---

output "service_dns_name" {
  description = "VPC Lattice Services."
  value       = module.myservice.services.myservice.attributes.dns_entry[0].domain_name
}

output "service_id" {
  description = "VPC Lattice Service ID."
  value       = { for k, v in module.myservice.services : k => v.attributes.id }
}

output "service_listeners" {
  description = "VPC Lattice listeners."
  value       = { for k, v in module.myservice.listeners_by_service : k => { for i, j in v : i => j.attributes.listener_id } }
}