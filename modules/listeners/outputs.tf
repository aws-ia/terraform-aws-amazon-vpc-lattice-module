# --- modules/listeners/outputs.tf ---

output "listeners" {
  description = "VPC Lattice Listeners created."
  value = { for k, v in aws_vpclattice_listener.lattice_listener : k => {
    attributes = v
    rules      = try(module.rules[k].rules, null)
    }
  }
}