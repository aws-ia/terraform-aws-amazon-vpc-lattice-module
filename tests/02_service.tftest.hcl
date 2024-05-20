
run "plan_service" {
  command = plan
  module {
    source = "./examples/service"
  }
}

run "apply_service" {
  command = apply
  module {
    source = "./examples/service"
  }
}