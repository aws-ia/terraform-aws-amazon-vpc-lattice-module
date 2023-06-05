# --- modules/targets/main.tf ---

# VPC Lattice Target Group attachment
resource "aws_vpclattice_target_group_attachment" "target_attachment" {
  for_each = var.targets

  target_group_identifier = var.target_group_identifier

  target {
    id   = try(each.value.id, null)
    port = try(each.value.port, null)
  }
}