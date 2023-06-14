<!-- BEGIN_TF_DOCS -->
# Amazon VPC Lattice - Example: Service Network creation

This example shows how you can use the VPC Lattice module to only create a Service Network - without other components. In the `outputs.tf` file, you can see an example on how to obtain the Service Network information (ID and ARN).

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
| <a name="module_vpclattice_service_network"></a> [vpclattice\_service\_network](#module\_vpclattice\_service\_network) | ../.. | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region to use. | `string` | `"eu-west-1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_service_network_arn"></a> [service\_network\_arn](#output\_service\_network\_arn) | VPC Lattice Service Network ARN. |
| <a name="output_service_network_id"></a> [service\_network\_id](#output\_service\_network\_id) | VPC Lattice Service Network ID. |
<!-- END_TF_DOCS -->