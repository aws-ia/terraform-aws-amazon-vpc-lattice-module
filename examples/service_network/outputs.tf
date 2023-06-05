# --- examples/service_network/outputs.tf ---

output "service_network_id" {
  description = "VPC Lattice Service Network ID."
  value       = module.vpclattice_service_network.service_network.id
}

output "service_network_arn" {
  description = "VPC Lattice Service Network ARN."
  value       = module.vpclattice_service_network.service_network.arn
}