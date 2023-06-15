<!-- BEGIN_TF_DOCS -->
# Amazon VPC Lattice - Example: Service Associations

This example shows how you can use the VPC Lattice module to create Service Associations to an existing Service Network (created in a separate call of the VPC Lattice module). In the `outputs.tf` file, you can see an example on how to obtain the Services information (ID, DNS name, and Service Association ID).

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
| <a name="module_service_network"></a> [service\_network](#module\_service\_network) | ../.. | n/a |
| <a name="module_services"></a> [services](#module\_services) | ../.. | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region to use. | `string` | `"eu-west-1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_services"></a> [services](#output\_services) | VPC Lattice Service ID. |
<!-- END_TF_DOCS -->