<!-- BEGIN_TF_DOCS -->
# Amazon VPC Lattice - Example: DNS configuration

This example shows how you can use the VPC Lattice module to configure DNS resolution (creation of Alias records) when creation VPC Lattice services with custom domain names. This example creates the following:

* Two Amazon Route 53 private hosted zones, and one VPC (needed for the configuration of the hosted zone as *private*).
* Eight VPC Lattice services with basic configuration (without listeners or targets).
* When configured, the custom domain name provided in each service's definition will create an Alias record either in the *global* Private Hosted Zone (defined in `var.dns_configuration.private_hosted_zone_id`) or in the *specific* PHZ (defined in the attribute `private_hosted_zone_id` under the service's configuration in `var.services`).

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.66.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.66.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_dns_resolution_example1"></a> [dns\_resolution\_example1](#module\_dns\_resolution\_example1) | ../.. | n/a |
| <a name="module_dns_resolution_example3"></a> [dns\_resolution\_example3](#module\_dns\_resolution\_example3) | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_route53_zone.global_private_hosted_zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_route53_zone.specific_private_hosted_zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_vpclattice_service.service2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpclattice_service) | resource |
| [aws_vpclattice_service.service4](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpclattice_service) | resource |
| [aws_vpclattice_service.service6](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpclattice_service) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region to use. | `string` | `"eu-west-1"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->