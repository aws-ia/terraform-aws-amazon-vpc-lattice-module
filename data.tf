# --- root/data.tf ---

locals {
  # ---------- VPC Lattice Service Network variables -----------
  # Determine if a Service Network should be created
  create_service_network = contains(keys(var.service_network), "name")
  # Service Network identifier
  service_network = local.create_service_network ? aws_vpclattice_service_network.lattice_service_network[0].id : try(var.service_network.identifier, null)
  # Service Network ARN
  service_network_arn = local.create_service_network ? aws_vpclattice_service_network.lattice_service_network[0].arn : try(var.service_network.identifier, null)
  # Checking if Service Network identifier was provided by the user
  sn_identifier_provided = contains(keys(var.service_network), "identifier")
  # Checking if Service Network auth policy should be created
  sn_auth_policy = (try(var.service_network.auth_type, "NONE") == "AWS_IAM") && (contains(keys(var.service_network), "auth_policy"))

  # ---------- VPC Lattice Service variables ---------
  # Service Association - if Service Network is created or passed
  create_service_association = local.create_service_network || local.sn_identifier_provided

  # ---------- VPC Lattice Target Groups ----------
  # We create a map of target group IDs
  target_group_ids = merge(
    try({ for k, v in aws_vpclattice_target_group.lambda_lattice_target_group : k => v.id }, {}),
    try({ for k, v in aws_vpclattice_target_group.lattice_target_group : k => v.id }, {}),
  )
}

# Sanitizes tags for aws provider
module "tags" {
  source  = "aws-ia/label/aws"
  version = "0.0.5"

  tags = var.tags
}