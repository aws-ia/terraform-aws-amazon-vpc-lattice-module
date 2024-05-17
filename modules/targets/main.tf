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

# AWS Lambda permission (only if LAMDBA type)
resource "aws_lambda_permission" "lambda_target_vpclattice" {
  for_each = {
    for k, v in var.targets : k => v
    if var.target_type == "LAMBDA"
  }

  statement_id  = "AllowExecutionFromVpcLattice"
  action        = "lambda:InvokeFunction"
  function_name = split(":", each.value.id)[6]
  principal     = "vpc-lattice.amazonaws.com"
  source_arn    = var.target_group_identifier
}