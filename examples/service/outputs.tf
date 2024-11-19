# --- examples/service/outputs.tf ---

output "service_attributes" {
  description = "VPC Lattice Service ID."
  value       = { for k, v in module.service_customdomainname_noauth.services : k => v.attributes }
}

output "service_sn_association" {
  description = "VPC Lattice service association."
  value       = { for k, v in module.service_associations.services : k => v.service_network_association }
}

output "service_listeners" {
  description = "VPC Lattice listeners."
  value = {
    http_listener  = module.service_httplistener.listeners_by_service.myservice.http_listener.attributes
    https_listener = { for k, v in module.service_httpslistener.listeners_by_service : k => { for i, j in v : i => j.attributes.listener_id } }
  }
}

output "service_listener_rules" {
  description = "VPC Lattice listener rules."
  value       = module.service_httplistener.listeners_by_service.myservice.http_listener.rules
}