<!-- BEGIN_TF_DOCS -->
# Amazon VPC Lattice - VPC Lattice service examples

This example shows how you can use the VPC Lattice module to create VPC Lattice services. The following examples are covered:

1. VPC Lattice service configured with a custom domain name and no auth policy. Access logs are configured for CloudWatch logs, S3, and Data Firehose.
2. VPC Lattice service configured with auth type "AWS\_IAM".
3. VPC Lattice services associated to a service network.
4. VPC Lattice service with HTTP listener.
    * Default action fixed-response (404)
    * Rule 1 (priority 10) - If prefix "/lambda", sends all the traffic to *target1*
    * Rule 2 (priority 20) - If header "target = instance", sends a fixed-response (404)
5. VPC Lattice service with HTTPS listener (forward default action)

In the `outputs.tf` file, you can see an example on how to obtain VPC Lattice service attributes, associations' information, access log subscriptions' information, listeners and rules.

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
| <a name="module_service_associations"></a> [service\_associations](#module\_service\_associations) | ../.. | n/a |
| <a name="module_service_auth"></a> [service\_auth](#module\_service\_auth) | ../.. | n/a |
| <a name="module_service_customdomainname_noauth"></a> [service\_customdomainname\_noauth](#module\_service\_customdomainname\_noauth) | ../.. | n/a |
| <a name="module_service_httplistener"></a> [service\_httplistener](#module\_service\_httplistener) | ../.. | n/a |
| <a name="module_service_httpslistener"></a> [service\_httpslistener](#module\_service\_httpslistener) | ../.. | n/a |
| <a name="module_service_network"></a> [service\_network](#module\_service\_network) | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.service_network_loggroup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_role.firehose_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_kinesis_firehose_delivery_stream.service_network_deliverystream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kinesis_firehose_delivery_stream) | resource |
| [aws_s3_bucket.service_network_logbucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [random_string.random](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_iam_policy_document.firehose_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region to use. | `string` | `"eu-west-1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_service_attributes"></a> [service\_attributes](#output\_service\_attributes) | VPC Lattice Service ID. |
| <a name="output_service_listener_rules"></a> [service\_listener\_rules](#output\_service\_listener\_rules) | VPC Lattice listener rules. |
| <a name="output_service_listeners"></a> [service\_listeners](#output\_service\_listeners) | VPC Lattice listeners. |
| <a name="output_service_log_subscriptions"></a> [service\_log\_subscriptions](#output\_service\_log\_subscriptions) | VPC Lattice service log subscriptions. |
| <a name="output_service_sn_association"></a> [service\_sn\_association](#output\_service\_sn\_association) | VPC Lattice service association. |
<!-- END_TF_DOCS -->