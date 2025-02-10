# --- examples/service_network/outputs.tf ---

output "service_network_id" {
  description = "VPC Lattice service network ID."
  value       = module.vpclattice_service_network_without_policy.service_network.id
}

output "service_network_arn" {
  description = "VPC Lattice service network ARN."
  value       = module.vpclattice_service_network_without_policy.service_network.arn
}

output "service_network_log_subscriptions" {
  description = "VPC Lattice service network log subscriptions."
  value       = module.vpclattice_service_network_without_policy.service_network_log_subscriptions
}

output "service_network" {
  description = "VPC Lattice service network (full output)."
  value       = module.vpclattice_service_network_with_policy.service_network
}

output "vpc_associations" {
  description = "VPC Lattice VPC association IDs."
  value       = { for k, v in module.vpclattice_vpc_associations.vpc_associations : k => v.id }
}