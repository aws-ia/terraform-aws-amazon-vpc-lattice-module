<!-- BEGIN_TF_DOCS -->
# Amazon VPC Lattice - Example: VPC associations

This example shows how you can use the VPC Lattice module to create VPC associations to an existing Service Network. Outside the module, the VPC Lattice Service Network and VPCs will be created, and the module will be used only for the VPC association creation. In the `outputs.tf` file, you can see an example on how to obtain the VPC association information (ID).

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
| <a name="module_vpclattice_vpc_associations"></a> [vpclattice\_vpc\_associations](#module\_vpclattice\_vpc\_associations) | ../.. | n/a |
| <a name="module_vpcs"></a> [vpcs](#module\_vpcs) | aws-ia/vpc/aws | 4.2.1 |

## Resources

| Name | Type |
|------|------|
| [aws_vpclattice_service_network.service_network](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpclattice_service_network) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region to use. | `string` | `"eu-west-1"` | no |
| <a name="input_vpcs"></a> [vpcs](#input\_vpcs) | VPCs to create. | `map(any)` | <pre>{<br>  "vpc1": {<br>    "cidr_block": "10.0.0.0/24",<br>    "number_azs": 2<br>  },<br>  "vpc2": {<br>    "cidr_block": "10.0.1.0/24",<br>    "number_azs": 2<br>  }<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vpc_associations"></a> [vpc\_associations](#output\_vpc\_associations) | VPC Lattice VPC association IDs. |
<!-- END_TF_DOCS -->