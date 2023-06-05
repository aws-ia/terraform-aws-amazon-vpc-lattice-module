# --- examples/vpc_associations/outputs.tf ---

output "vpc_associations" {
  description = "VPC Lattice VPC association IDs."
  value       = { for k, v in module.vpclattice_vpc_associations.vpc_associations : k => v.id }
}