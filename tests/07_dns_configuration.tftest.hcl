
run "plan_ram_share" {
  command = plan
  module {
    source = "./examples/dns_configuration"
  }
}

run "apply_ram_share" {
  command = apply
  module {
    source = "./examples/dns_configuration"
  }
}