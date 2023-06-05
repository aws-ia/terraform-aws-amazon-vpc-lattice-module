# --- examples/service_network/main.tf ---

module "vpclattice_service_network" {
  source = "../.."

  service_network = {
    name      = "service-network"
    auth_type = "AWS_IAM"
    auth_policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action    = "*"
          Effect    = "Allow"
          Principal = "*"
          Resource  = "*"
          Condition = {
            StringNotEqualsIgnoreCase = {
              "aws:PrincipalType" = "anonymous"
            }
          }
        }
      ]
    })
  }
}