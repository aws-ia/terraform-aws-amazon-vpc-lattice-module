# --- examples/target_groups/outputs.tf ---

output "target_groups" {
  description = "Target Group IDs."
  value       = { for k, v in module.vpclattice_target_groups.target_groups : k => v.id }
}