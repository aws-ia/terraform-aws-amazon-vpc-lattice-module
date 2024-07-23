<!-- BEGIN_TF_DOCS -->
# Amazon VPC Lattice - Example: AWS RAM share

This example shows how you can use the VPC Lattice module to share service networks and services using [AWS Resource Access Manager](https://aws.amazon.com/ram/) RAM. The example creates the following:

* 1 VPC Lattice service network.
* 3 VPC Lattice services - basic configuration (without listeners or targets).
* 2 RAM shares. One is sharing the service network, and the other one is sharing 2 out of the 3 VPC Lattice services created.

**NOTE**: Given we automate these examples before merging new PRs, there's an [AWS Systems Manager parameter](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-parameter-store.html) data source configured to obtain an Account ID from a parameter configured in the AWS Account we use for the automated tests. Take that into account when doing your own tests, and please remember to keep this configuration when doing any PR to this repository.

In the `outputs.tf` file, you can see an example on how to obtain the information about the RAM share created (if applicable).

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
| <a name="module_vpclattice_service_network_share"></a> [vpclattice\_service\_network\_share](#module\_vpclattice\_service\_network\_share) | ../.. | n/a |
| <a name="module_vpclattice_services_share"></a> [vpclattice\_services\_share](#module\_vpclattice\_services\_share) | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_ram_resource_share.vpclattice_resource_share](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_share) | resource |
| [aws_ssm_parameter.account_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region to use. | `string` | `"eu-west-1"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->