<!-- BEGIN_TF_DOCS -->
# Amazon VPC Lattice - VPC Lattice service network examples

This example shows how you can use the VPC Lattice module to create VPC Lattice service networks and VPC associations. The following examples are covered:

1. VPC Lattice service network without auth policy configured. Access logs are configured for CloudWatch logs, S3, and Data Firehose.
2. VPC Lattice service network with auth policy configured.
3. VPC Lattice service network created outside the module and referenced in the module.
4. VPC Lattice service network VPC associations.

In the `outputs.tf` file, you can see an example on how to obtain the VPC Lattice service network ID and ARN, access logs subscription information, and VPC associations' ID.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.66.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.66.0 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vpclattice_service_network_referenced"></a> [vpclattice\_service\_network\_referenced](#module\_vpclattice\_service\_network\_referenced) | ../.. | n/a |
| <a name="module_vpclattice_service_network_with_policy"></a> [vpclattice\_service\_network\_with\_policy](#module\_vpclattice\_service\_network\_with\_policy) | ../.. | n/a |
| <a name="module_vpclattice_service_network_without_policy"></a> [vpclattice\_service\_network\_without\_policy](#module\_vpclattice\_service\_network\_without\_policy) | ../.. | n/a |
| <a name="module_vpclattice_vpc_associations"></a> [vpclattice\_vpc\_associations](#module\_vpclattice\_vpc\_associations) | ../.. | n/a |
| <a name="module_vpcs"></a> [vpcs](#module\_vpcs) | aws-ia/vpc/aws | 4.4.4 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.service_network_loggroup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_role.firehose_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_kinesis_firehose_delivery_stream.service_network_deliverystream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kinesis_firehose_delivery_stream) | resource |
| [aws_s3_bucket.service_network_logbucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_vpclattice_service_network.external_service_network](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpclattice_service_network) | resource |
| [random_string.random](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_iam_policy_document.firehose_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region to use. | `string` | `"eu-west-1"` | no |
| <a name="input_vpcs"></a> [vpcs](#input\_vpcs) | VPCs to create. | `map(any)` | <pre>{<br>  "vpc1": {<br>    "cidr_block": "10.0.0.0/24",<br>    "number_azs": 2<br>  },<br>  "vpc2": {<br>    "cidr_block": "10.0.1.0/24",<br>    "number_azs": 2<br>  }<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_service_network"></a> [service\_network](#output\_service\_network) | VPC Lattice service network (full output). |
| <a name="output_service_network_arn"></a> [service\_network\_arn](#output\_service\_network\_arn) | VPC Lattice service network ARN. |
| <a name="output_service_network_id"></a> [service\_network\_id](#output\_service\_network\_id) | VPC Lattice service network ID. |
| <a name="output_service_network_log_subscriptions"></a> [service\_network\_log\_subscriptions](#output\_service\_network\_log\_subscriptions) | VPC Lattice service network log subscriptions. |
| <a name="output_vpc_associations"></a> [vpc\_associations](#output\_vpc\_associations) | VPC Lattice VPC association IDs. |
<!-- END_TF_DOCS -->