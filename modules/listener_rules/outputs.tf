# --- modules/listener_rules/outputs.tf ---

output "rules" {
  description = "Listener rules created."
  value       = aws_vpclattice_listener_rule.lattice_listener_rule
}