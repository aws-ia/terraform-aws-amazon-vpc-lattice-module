# --- modules/listener_rules/main.tf ---

# VPC Lattice Listener Rules
resource "aws_vpclattice_listener_rule" "lattice_listener_rule" {
  for_each = var.listener_rules

  name                = try(each.value.name, each.key)
  listener_identifier = var.listener_identifier
  service_identifier  = var.service_identifier
  priority            = each.value.priority

  match {
    http_match {
      method = try(each.value.http_match_method, null)

      # Dynamic block - header_matches
      dynamic "header_matches" {
        for_each = try(each.value.header_matches[*], [])
        content {
          case_sensitive = try(header_matches.value.case_sensitive, false)
          name           = header_matches.value.name

          match {
            contains = try(header_matches.value.contains, null)
            exact    = try(header_matches.value.exact, null)
            prefix   = try(header_matches.value.prefix, null)
          }
        }
      }

      # Dynamic block - path_match
      dynamic "path_match" {
        for_each = try(each.value.path_match[*], [])
        content {
          case_sensitive = try(path_match.value.case_sensitive, false)

          match {
            exact  = try(path_match.value.exact, null)
            prefix = try(path_match.value.prefix, null)
          }
        }
      }
    }
  }

  # Dynamic block - action = fixed_response
  dynamic "action" {
    for_each = try(each.value.action_fixedresponse[*], [])
    content {
      fixed_response {
        status_code = action.value.status_code
      }
    }
  }

  # Dynamic block - action = forward
  dynamic "action" {
    for_each = try(each.value.action_forward[*], [])
    content {
      forward {
        dynamic "target_groups" {
          for_each = try(action.value.target_groups, [])
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