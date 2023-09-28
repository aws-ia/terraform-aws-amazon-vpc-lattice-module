# --- root/main.tf ---

# ---------- VPC LATTICE SERVICE NETWORK ----------
resource "aws_vpclattice_service_network" "lattice_service_network" {
  count = local.create_service_network ? 1 : 0

  name      = var.service_network.name
  auth_type = try(var.service_network.auth_type, "NONE")

  tags = module.tags.tags_aws
}

# Auth policy
resource "aws_vpclattice_auth_policy" "service_network_auth_policy" {
  count = local.sn_auth_policy ? 1 : 0

  resource_identifier = local.service_network_arn
  policy              = var.service_network.auth_policy
}

# ---------- VPC LATTICE VPC ASSOCIATIONS ----------
resource "aws_vpclattice_service_network_vpc_association" "lattice_vpc_association" {
  for_each = var.vpc_associations

  vpc_identifier             = each.value.vpc_id
  service_network_identifier = local.service_network
  security_group_ids         = try(each.value.security_group_ids, null)

  tags = module.tags.tags_aws
}

# ---------- VPC LATTICE SERVICES ----------
# VPC Lattice Service
resource "aws_vpclattice_service" "lattice_service" {
  for_each = {
    for k, v in var.services : k => v
    if try(v.name, null) != null
  }

  name               = each.value.name
  auth_type          = try(each.value.auth_type, "NONE")
  certificate_arn    = try(each.value.certificate_arn, null)
  custom_domain_name = try(each.value.custom_domain_name, null)

  tags = module.tags.tags_aws
}

# Auth policy
resource "aws_vpclattice_auth_policy" "service_auth_policy" {
  for_each = {
    for k, v in var.services : k => v
    if(try(v.auth_type, "NONE") == "AWS_IAM") && (try(v.auth_policy, null) != null)
  }

  resource_identifier = try(aws_vpclattice_service.lattice_service[each.key].arn, each.value.identifier)
  policy              = each.value.auth_policy
}

# VPC Lattice Service Association (only if Service Network is created or provided)
resource "aws_vpclattice_service_network_service_association" "lattice_service_association" {
  for_each = {
    for k, v in var.services : k => v
    if local.create_service_association
  }

  service_identifier         = try(each.value.identifier, aws_vpclattice_service.lattice_service[each.key].id)
  service_network_identifier = local.service_network

  tags = module.tags.tags_aws
}

# Data Source: Lattice Service. Used to obtain the information of the Services not created by the module, but its identifier was passed in var.services
data "aws_vpclattice_service" "lattice_service" {
  for_each = { for k, v in var.services : k => v if try(v.name, null) == null }

  service_identifier = each.value.identifier
}

# ---------- VPC LATTICE TARGET GROUPS ----------
# AWS Lambda Target Group (without config attribute)
resource "aws_vpclattice_target_group" "lambda_lattice_target_group" {
  for_each = {
    for k, v in var.target_groups : k => v
    if v.type == "LAMBDA"
  }

  name = try(each.value.name, each.key)
  type = each.value.type

  tags = module.tags.tags_aws
}

# Other Target Groups
resource "aws_vpclattice_target_group" "lattice_target_group" {
  for_each = {
    for k, v in var.target_groups : k => v
    if v.type != "LAMBDA"
  }

  name = try(each.value.name, each.key)
  type = each.value.type

  config {
    port             = try(each.value.config.port, null)
    protocol         = try(each.value.config.protocol, null)
    vpc_identifier   = try(each.value.config.vpc_identifier, null)
    ip_address_type  = try(each.value.config.ip_address_type, null)
    protocol_version = try(each.value.config.protocol_version, null)

    dynamic health_check {
      for_each = {
        for k, v in var.target_groups : k => v
        if v.type != "ALB"
      }

      content {
        enabled                       = try(each.value.health_check.enabled, true)
        health_check_interval_seconds = try(each.value.health_check.health_check_interval_seconds, null)
        health_check_timeout_seconds  = try(each.value.health_check.health_check_timeout_seconds, null)
        healthy_threshold_count       = try(each.value.health_check.healthy_threshold_count, null)
        path                          = try(each.value.health_check.path, null)
        port                          = try(each.value.health_check.port, null)
        protocol                      = try(each.value.health_check.protocol, null)
        protocol_version              = try(each.value.health_check.protocol_version, null)
        unhealthy_threshold_count     = try(each.value.health_check.unhealthy_threshold_count, null)

        matcher {
          value = try(each.value.health_check.matcher, null)
        }
      }
    }
  }

  tags = module.tags.tags_aws
}

# VPC Lattice Targets
module "targets" {
  for_each = {
    for k, v in var.target_groups : k => v.targets
    if contains(keys(v), "targets")
  }
  source = "./modules/targets"

  target_group_identifier = try(aws_vpclattice_target_group.lambda_lattice_target_group[each.key].id, aws_vpclattice_target_group.lattice_target_group[each.key].id)
  targets                 = each.value
}

# ---------- LISTENERS AND RULES ----------
# VPC Lattice Listeners - rules are handled inside the "listeners" module
module "listeners" {
  source   = "./modules/listeners"
  for_each = var.services

  listener_information = try(each.value.listeners, {})
  service_identifier   = try(each.value.identifier, aws_vpclattice_service.lattice_service[each.key].id)
  target_groups        = local.target_group_ids
  tags                 = module.tags.tags_aws
}