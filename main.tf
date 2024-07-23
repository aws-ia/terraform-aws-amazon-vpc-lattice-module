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
  for_each = { for k, v in var.services : k => v if contains(keys(v), "identifier") }

  service_identifier = each.value.identifier
}

# ---------- AMAZON ROUTE 53 DNS CONFIGURATION ----------
resource "aws_route53_record" "custom_domain_name_record" {
  for_each = local.services_with_dns_config

  zone_id = try(each.value.private_hosted_zone_id, var.dns_configuration.private_hosted_zone_id)
  name    = try(var.services[each.key].custom_domain_name, data.aws_vpclattice_service.lattice_service[each.key].custom_domain_name)
  type    = "A"

  alias {
    name                   = try(aws_vpclattice_service.lattice_service[each.key].dns_entry[0].domain_name, data.aws_vpclattice_service.lattice_service[each.key].dns_entry[0].domain_name)
    zone_id                = try(aws_vpclattice_service.lattice_service[each.key].dns_entry[0].hosted_zone_id, data.aws_vpclattice_service.lattice_service[each.key].dns_entry[0].hosted_zone_id)
    evaluate_target_health = false
  }
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

  config {
    lambda_event_structure_version = try(each.value.config.lambda_event_structure_version, "V2")
  }

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

    dynamic "health_check" {
      for_each = each.value.type != "ALB" ? each.value.health_check[*] : []

      content {
        enabled                       = try(health_check.value.enabled, true)
        health_check_interval_seconds = try(health_check.value.health_check_interval_seconds, null)
        health_check_timeout_seconds  = try(health_check.value.health_check_timeout_seconds, null)
        healthy_threshold_count       = try(health_check.value.healthy_threshold_count, null)
        path                          = try(health_check.value.path, null)
        port                          = try(health_check.value.port, null)
        protocol                      = try(health_check.value.protocol, null)
        protocol_version              = try(health_check.value.protocol_version, null)
        unhealthy_threshold_count     = try(health_check.value.unhealthy_threshold_count, null)

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
    for k, v in var.target_groups : k => v
    if contains(keys(v), "targets")
  }
  source = "./modules/targets"

  target_type             = each.value.type
  target_group_identifier = try(aws_vpclattice_target_group.lambda_lattice_target_group[each.key].arn, aws_vpclattice_target_group.lattice_target_group[each.key].arn)
  targets                 = each.value.targets
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

# ---------- AWS RESOURCE ACCESS MANAGER ----------
# Create AWS RAM Resource Share (if name provided)
resource "aws_ram_resource_share" "ram_resource_share" {
  count = local.create_ram_resource_share ? 1 : 0

  name                      = var.ram_share.resource_share_name
  allow_external_principals = try(var.ram_share.allow_external_principals, false)

  tags = module.tags.tags_aws
}

# AWS RAM principal association
resource "aws_ram_principal_association" "ram_principal_association" {
  for_each = {
    for k, v in local.principals_map : k => v
    if local.config_ram_share
  }

  principal          = each.value
  resource_share_arn = local.resource_share_arn
}

# AWS RAM resource association - VPC Lattice service network
resource "aws_ram_resource_association" "ram_service_network_association" {
  count = local.share_service_network ? 1 : 0

  resource_arn       = aws_vpclattice_service_network.lattice_service_network[0].arn
  resource_share_arn = local.resource_share_arn
}

# AWS RAM resource association - VPC Lattice services
resource "aws_ram_resource_association" "ram_services_association" {
  count = local.config_ram_share ? length(local.share_services) : 0

  resource_arn       = aws_vpclattice_service.lattice_service[local.share_services[count.index]].arn
  resource_share_arn = local.resource_share_arn
}