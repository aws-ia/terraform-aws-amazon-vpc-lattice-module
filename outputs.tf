# --- root/outputs.tf ---

output "service_network" {
  value       = try(aws_vpclattice_service_network.lattice_service_network[0], null)
  description = <<-EOF
  VPC Lattice resource attributes. Full output of **aws_vpclattice_service_network**.
EOF
}

output "service_network_log_subscriptions" {
  value = {
    cloudwatch = try(aws_vpclattice_access_log_subscription.service_network_cloudwatch_access_log[0], null)
    s3         = try(aws_vpclattice_access_log_subscription.service_network_s3_access_log[0], null)
    firehose   = try(aws_vpclattice_access_log_subscription.service_network_firehose_access_log[0], null)
  }
  description = <<-EOF
  VPC Lattice service network access log subscriptions. The output is composed by the following attributes:
  - `cloudwatch` = Full output of **aws_vpclattice_access_log_subscription**.
  - `s3`         = Full output of **aws_vpclattice_access_log_subscription**.
  - `firehose`   = Full output of **aws_vpclattice_access_log_subscription**.
EOF
}

output "vpc_associations" {
  value       = try(aws_vpclattice_service_network_vpc_association.lattice_vpc_association, null)
  description = <<-EOF
  VPC Lattice VPC associations. Full output of **aws_vpclattice_service_network_vpc_association**.
EOF
}

output "services" {
  value = { for k, v in var.services : k => {
    attributes                  = try(aws_vpclattice_service.lattice_service[k], data.aws_vpclattice_service.lattice_service[k])
    service_network_association = try(aws_vpclattice_service_network_service_association.lattice_service_association[k], null)
    log_subscriptions = {
      cloudwatch = try(aws_vpclattice_access_log_subscription.service_cloudwatch_access_log[k], null)
      s3         = try(aws_vpclattice_access_log_subscription.service_s3_access_log[k], null)
      firehose   = try(aws_vpclattice_access_log_subscription.service_firehose_access_log[k], null)
    }
  } }
  description = <<-EOF
  VPC Lattice Services. The output is composed by the following attributes (per Service created):
  - `attributes`                  = Full output of **aws_vpclattice_service**.
  - `service_network_association` = Full output of **aws_vpclattice_service_network_service_association**.
  - `log_subscriptions`           = *The output is composed by the following attributes:*
    - `cloudwatch` = Full output of **aws_vpclattice_access_log_subscription**.
    - `s3`         = Full output of **aws_vpclattice_access_log_subscription**.
    - `firehose`   = Full output of **aws_vpclattice_access_log_subscription**.
EOF
}

output "target_groups" {
  value       = { for k, v in var.target_groups : k => try(aws_vpclattice_target_group.lambda_lattice_target_group[k], try(aws_vpclattice_target_group.lattice_target_group[k], null)) }
  description = <<-EOF
  VPC Lattice Target Groups. Full output of **aws_vpclattice_target_group**.
EOF
}

output "listeners_by_service" {
  value       = try({ for k, v in module.listeners : k => v.listeners }, null)
  description = <<-EOF
  VPC Lattice Listener and Rules. Per Lattice Service, each Listener is composed by the following attributes:
  - `attributes` = Full output of **aws_vpclattice_listener**.
  - `rules`      = Full output of **aws_vpclattice_listener_rule**.
EOF
}

output "ram_resource_share" {
  value       = try(aws_ram_resource_share.ram_resource_share[0], null)
  description = <<-EOF
  AWS Resource Access Manager resource share. Full output of **aws_ram_resource_share**.
EOF
}