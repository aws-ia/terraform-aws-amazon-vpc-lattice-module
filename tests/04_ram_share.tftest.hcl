
run "plan_ram_share" {
  command = plan
  module {
    source = "./examples/ram_share"
  }
}

run "apply_ram_share" {
  command = apply
  module {
    source = "./examples/ram_share"
  }
}