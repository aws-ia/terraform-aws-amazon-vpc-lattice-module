<!-- BEGIN_TF_DOCS -->
# Amazon VPC Lattice - Example: Service creation

This example shows how you can use the VPC Lattice module to only create a Service - without the creation of a Service Network. In the Service, the example also creates the following:

* 2 Listeners (HTTP and HTTPS).
* The HTTP listener has a *fixed-response* as default action, and two Listener Rules (*path\_match* and *headers\_match*).
* The HTTPS listener has a *forward* as default action.
* Three target groups (1 Instance and 2 Lambda types) without targets.

In the `outputs.tf` file, you can see an example on how to obtain the Service Network information (DNS name, Service ID, and Listeners IDs).

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.66.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_myservice"></a> [myservice](#module\_myservice) | ../.. | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | aws-ia/vpc/aws | 4.4.1 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region to use. | `string` | `"eu-west-1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_service_dns_name"></a> [service\_dns\_name](#output\_service\_dns\_name) | VPC Lattice Services. |
| <a name="output_service_id"></a> [service\_id](#output\_service\_id) | VPC Lattice Service ID. |
| <a name="output_service_listeners"></a> [service\_listeners](#output\_service\_listeners) | VPC Lattice listeners. |
<!-- END_TF_DOCS -->