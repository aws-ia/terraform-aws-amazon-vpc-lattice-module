# --- modules/listeners/main.tf ---

# VPC Lattice Listener
resource "aws_vpclattice_listener" "lattice_listener" {
  for_each = var.listener_information

  name               = try(each.value.name, each.key)
  port               = try(each.value.port, null)
  protocol           = each.value.protocol
  service_arn        = can(regex("^svc-", var.service_identifier)) ? null : var.service_identifier
  service_identifier = can(regex("^svc-", var.service_identifier)) ? var.service_identifier : null

  # Dynamic block for default_action = fixed_response.
  dynamic "default_action" {
    for_each = try(each.value.default_action_fixedresponse[*], [])
    content {
      fixed_response {
        status_code = default_action.value.status_code
      }
    }
  }

  # Dynamic block for default_action = forward.
  dynamic "default_action" {
    for_each = try(each.value.default_action_forward[*], [])
    content {
      forward {
        dynamic "target_groups" {
          for_each = try(default_action.value.target_groups, [])
          content {
            target_group_identifier = var.target_groups[target_groups.key]
            weight                  = target_groups.value.weight
          }
        }
      }
    }
  }

  tags = var.tags
}

# VPC Lattice Listener rules
module "rules" {
  source = "../../modules/listener_rules"
  for_each = {
    for k, v in aws_vpclattice_listener.lattice_listener : k => v.listener_id
    if try(var.listener_information[k].rules, null) != null
  }

  listener_rules      = var.listener_information[each.key].rules
  listener_identifier = each.value
  service_identifier  = var.service_identifier
  target_groups       = var.target_groups
  tags                = var.tags
}