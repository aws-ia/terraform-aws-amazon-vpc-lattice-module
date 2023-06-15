# Amazon VPC Lattice Module

This module can be used to deploy resources from [Amazon VPC Lattice](https://docs.aws.amazon.com/vpc-lattice/latest/ug/what-is-vpc-service-network.html). VPC Lattice is a fully managed application networking service that you use to connect, secure, and monitor all your services across multiple accounts and virtual private clouds (VPCs).

## Usage

This module handles all the different resources you can use with VPC Lattice: Service Network, Service, Listeners, Listener Rules, Target Groups (and targets), and Associations (Service or VPC). You have the freedom to create the combination of resources you need, so in multi-AWS Account environments you can make use of the module as many times as needed (different providers) to create your application network architecture.

### Service Network (var.service\_network)

A Service Network is a logical boundary for a collection of services. It is the central place of connectivity where consumers (located in a VPC) and producers (target groups) are connected to allow service consumption.

You can configure centrally security by using IAM policies for access control, and visibility by enabling logs in the Service Network.

When creating a Service Network in the module, the following attributes are expected:

- `name`        = (Optional|string) Name of the Service Network. If `create_service_network` is `true`, this value is required. **This attribute and `identifier` cannot be set at the same time.**
- `auth_type`   = (Optional|string) Type of IAM policy to apply in the service network. Allowed values are `NONE` (default) `AWS_IAM`.
- `auth_policy` = (Optional|any) Auth policy. The policy string in JSON must not contain newlines or blank lines. The auth policy resource will be created only if `auth_type` is set to `AWS_IAM`.
- `identifier`  = (Optional|string) The ID or ARN of an existing service network. If you are working in multi-AWS account environments, ARN is compulsory. **This attribute and `name` cannot be set at the same time.**

Example of creating a service network with `auth_type` equals to `NONE`:

```hcl
service_network = {
    name      = "service-network"
    auth_type = "NONE"
}
```

Example of creating a service network with `auth_type` equals to `AWS_IAM`:

```hcl
service_network = {
    name        = "service-network"
    auth_type   = "AWS_IAM"
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
```

Example of referencing an existing service network into the module:

```hcl
service_network = {
    identifier = "sn-XXX"
}
```

### VPC associations (var.vpc\_associations)

When you associate a VPC with a service network, it enables all the targets within that VPC to be clients and communicate with other services associated to that same service network. You can make use of Security Groups to control the access of the VPC association, allowing some traffic segmentation before the traffic arrives to the Service Network.

You can create more than 1 VPC association with this module, as this variable expects a map of objects with the following attributes:

- `vpc_id`             = (string) ID of the VPC.
- `security_group_ids` = (Optional|list(string)) List of Security Group IDs to associate with the VPC association.

To create VPC associations, you need to either create a new Service Network with this module, or reference one using the `identifier` attribute within the `service_network` variable.

```hcl
vpc_associations = {
    vpc1 = {
        vpc_id             = "vpc-XXX"
        security_group_ids = ["sg-XXX", "sg-YYY"]
    }
    vpc2 = {
        vpc_id = "vpc-YYY
    }
}
```

### Target Groups (var.target\_groups)

A Target Group is a collection of targets, or compute resources that run your application or service. Targets in VPC Lattice can be EC2 instances, IP addresses, Lambda functions, Application Load Balancers, or Kubernetes Pods.

You can create more than 1 Target Groups with this module, as this variable expects a map of objects with the following attributes:

- `name`         = (Optional|string) The name of the target group. If not provided, the key of the map will be used as name.
- `type`         = (string) The type of target group. Valid Values are `IP`, `LAMBDA`, `INSTANCE`, `ALB`.
- `config`       = (Optional|map(any)) Target group configuration - more information about its definition below. If type is set to `LAMBDA`, this parameter should not be specified.
- `health_check` = (Optional|map(any)) Health check configuration - more information about its definition below.
- `targets`      = (Optional|map(any)) Targets to associate to the target group. If `type` is equals to `LAMBDA` or `ALB`, only one target can be defined. More information about its definition below.

**The key used for each of the target group definitions is the one expected when defining the Service Listeners and Rules (var.services)**, so make sure these values are unique.

The `config` attribute *- map(any) -* supports the following:

- `port`             = (number) Port on which the targets are listening.
- `protocol`         = (string) Protocol to use for routing traffic to the targets. Valid values: `HTTP` and `HTTPS`.
- `vpc_identifier`   = (string) VPC ID.
- `ip_address_type`  = (Optional|string) IP address type for the target group. Valid values: `IPV4` and `IPV6`.
- `protocol_version` = (Optional|string) Protocol version. Valid values: `HTTP1` (default), `HTTP2`, `GRCP`.

The `health_check` attribute *- map(any) -* supports the following:

- `enabled`                       = (Optional|bool) Whether health checks are enabled. Valid values: `true` (default) and `false`.
- `health_check_interval_seconds` = (Optional|number) The approximate amount of time, in seconds, between health checks of an individual target. The range is 5-300 seconds. The default is 30 seconds.
- `health_check_timeout_seconds`  = (Optional|number) The amount of time, in seconds, to wait before reporting a target as unhealthy. The range is 1-120 seconds. The default is 5 seconds.
- `healthy_threshold_count`       = (Optional|number) The number of consecutive successful health checks required before considering an unhealthy target healthy. The range is 2-10. The default is 5.
- `matcher`                       = (Optional|list(string)) List of HTTP codes to use when checking for a successful response from a target.
- `path`                          = (Optional|string) The destination for health checks on the targets. If the protocol version is HTTP/1.1 or HTTP/2, specify a valid URI (for example, /path?query). The default path is /. Health checks are not supported if the protocol version is gRPC, however, you can choose HTTP/1.1 or HTTP/2 and specify a valid URI.
- `port`                          = (Optional|number) The port used when performing health checks on targets. The default setting is the port that a target receives traffic on.
- `protocol`                      = (Optional|string) The protocol used when performing health checks on targets. The possible protocols are `HTTP` and `HTTPS`.
- `protocol_version`              = (Optional|string) The protocol version used when performing health checks on targets. The possible protocol versions are `HTTP1` (default) and `HTTP2`.
- `unhealthy_threshold_count`     = (Optional|number) The number of consecutive failed health checks required before considering a target unhealthy. The range is 2-10. The default is 2.

The `targets` attribute *- map(any) -* supports the following:

- `id`   = (Required|string) The ID of the target. If the target type of the target group is INSTANCE, this is an instance ID. If the target type is IP , this is an IP address. If the target type is LAMBDA, this is the ARN of the Lambda function. If the target type is ALB, this is the ARN of the Application Load Balancer.
- `port` = (Optional|number) The port on which the target is listening. For HTTP, the default is 80. For HTTPS, the default is 443. Attribute not needed with target type of `LAMBDA`.

Example of a `LAMBDA` type target group:

```hcl
target_groups = {
    lambdatarget = {
        name = "lambdatarget"
        type = "LAMBDA"
    }
}
```

Example of an `INSTANCE` and `IP` type target groups (without health checks): **(TO ADD TARGETS WHEN AVAILABLE)**

```hcl
target_groups = {
    instancetarget = {
        type = "INSTANCE"
        config = {
            port            = 80
            protocol        = "HTTP"
            vpc_identifier  = "vpc-XXX"
            ip_address_type = "IPV4"
        }
        health_check = {
            enabled = false
        }
        targets = {}
    }

    iptarget = {
        type = "IP"
        config = {
            port            = 443
            protocol        = "HTTPS"
            vpc_identifier  = "vpc-YYY"
            ip_address_type = "IPV4"
        }
        health_check = {
            enabled = false
        }
        targets = {}
    }
}
```

### Services (var.services)

A Service is an independently deployable unit of software that delivers a specific task or function. It can run on instances, containers, or as serverless functions within an account or a VPC. A service has a Listener that uses Rules (Listener Rules), that you can configure to help route traffic to your targets.

You can create more than 1 Service with this module, as this variable expects a map of objects with the following attributes:

- `identifier`         = (Optional|string) ID or ARN of the Lattice Service (if it was created outside this module). **This attribute and `name` cannot be set at the same time.**
- `name`               = (Optional|string) Name of the service - to create a new Lattice Service. **This attribute and `identifier` cannot be set at the same time.**
- `auth_type`          = (Optional|string) Type of IAM policy. Either `NONE` (default) or `AWS_IAM`.
- `auth_policy`        = (Optional|any) Auth policy. The policy string in JSON must not contain newlines or blank lines. The auth policy resource will be created only if `auth_type` is set to `AWS_IAM`.
- `certificate_arn`    = (Optional|string) ARN of the AWS Certificate Manager certificate to use.
- `custom_domain_name` = (Optional|string) Custom domain name for the service.
- `listeners`          = (Optional|map(string)) VPC Lattice listeners (and rules) to configure in the Service - more information about its definition below.

The attribute `listeners` (you can define more than 1) supports the following:

- `name`           = (Optional|string) Name of the listener. If this attribute is not defined, the key will be used as name.
- `port`           = (Optional|number) Listener port. You can specify a value from 1 to 65535. If not defined, the default values are 80 for `HTTP` and 443 for `HTTPS`.
- `protocol`       = (string) Protocol for the listener
- `default_action` = (map(any)) Default action block for the default listener rule - more information about its definition below.
- `rules`          = (Optional|any) Rules to define in a listener to determine how the Service routes requests to its registered targets - more information about its definition below.

The attribute `default_action` *- map(any) -* supports the following:

- `type`          = (string) Default action to apply in the listener. Allowed values are `fixed_response` and `forward`.
- `status_code`   = (Optional|number) Custom HTTP status codd to return. **To define if the default\_action type is `fixed-response`**.
- `target_groups` = (Optional|map(string)) Map of target groups to use in the listener's default action. **To define if the default\_action type is `forward`**. The map expects the following:
  - `target_group_identifier` = (string) Target group identifier. This identifier should be the specific map key defined in *var.target\_groups*.
  - `weight`                  = (Optional|number) Determines how requests are distributed to the target group. Only required if you specify multiple target groups for a forward action.

The attribute `rules` (you can define more than 1) supports the following:

- `name` = (Optional|string) Name for the Listener Rule. If not defined, the key will be use as name.
- `priority` = (number) The priority assigned to the rule. Each rule for a specific listener must have a unique priority. The lower the number the higher the priority.
- `http_match_method` = (Optional|string) The HTTP method type.
- `path_match` = (Optional|map(any)) The path match. **This attribute and `header_matches` cannot be set at the same time.**
  - `case_sensitive` = (Optional|bool) Indicates whether the match is case sensitive. Defaults to false.
  - `exact` = (Optional|string) Specifies an exact type match.
  - `prefix` = (Optional|string) Specifies a prefix type match. Matches the value with the prefix.
- `headers_match` = (Optional|map(any)) The header matches. Matches incoming requests with rule based on request header value before applying rule action. **This attribute and `path_match` cannot be set at the same time.**
  - `case_sensitive` = (Optional|bool) Indicates whether the match is case sensitive. Defaults to false.
  - `name` = (Optional|string) The name of the header.
  - `exact` = (Optional|string) Specifies an exact type match.
  - `prefix` = (Optional|string) Specifies a prefix type match. Matches the value with the prefix.
- `action_fixedresponse` = (Optional|map(string)) Describes the rule action that returns a custom HTTP response. **This attribute and `action_forward` cannot be set at the same time.**
  - `status_code` = (Optional|string) The HTTP response code.
- `action_forward` = (Optional|map(string)) The forward action. Traffic that matches the rule is forwarded to the specified target groups. **This attribute and `action_fixedresponse` cannot be set at the same time.**
  - `target_groups` = (Optional|map(any)) The target groups. You can define more than 1 target group. **The key of each target group should map the key you defined in var.target\_groups**.
    - `weight` = (Optional|number) With forward actions, you can assign a weight that controls the prioritization and selection of each target group.

Example of a service with an HTTP Listener (and two Listener rules):

```hcl
services = {
    myservice = {
      name = "myservice"
      listeners = {
        # HTTP listener
        http_listener = {
          name                         = "httplistener"
          port                         = 80
          protocol                     = "HTTP"
          default_action_fixedresponse = { status_code = 404 }
          rules = {
            lambdapath = {
              priority   = 10
              path_match = { prefix = "/lambda" }
              action_forward = {
                target_groups = {
                  lambdatargethttp = { weight = 100 }
                }
              }
            }
            instanceheader = {
              priority = 20
              header_matches = {
                name  = "target"
                exact = "instance"
              }
              action_fixedresponse = { status_code = 404 }
            }
          }
        }
      }
    }
}
```

Example of a service with an HTTPS Listener (without Listener rules):

```hcl
myservice = {
    identifier = "svc-XXX"
    listeners = {
        https_listener = {
            port     = 443
            protocol = "HTTPS"
            default_action_forward = {
                target_groups = {
                    instancetarget    = { weight = 50 }
                    lambdatargethttps = { weight = 50 }
                }
            }
        }
    }
}
```

Example of a service with auth type "AWS\_IAM":

```hcl
services = {
  myservice = {
    name      = "myservice"
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
```

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
| <a name="module_listeners"></a> [listeners](#module\_listeners) | ./modules/listeners | n/a |
| <a name="module_tags"></a> [tags](#module\_tags) | aws-ia/label/aws | 0.0.5 |
| <a name="module_targets"></a> [targets](#module\_targets) | ./modules/targets | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_vpclattice_auth_policy.service_auth_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpclattice_auth_policy) | resource |
| [aws_vpclattice_auth_policy.service_network_auth_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpclattice_auth_policy) | resource |
| [aws_vpclattice_service.lattice_service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpclattice_service) | resource |
| [aws_vpclattice_service_network.lattice_service_network](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpclattice_service_network) | resource |
| [aws_vpclattice_service_network_service_association.lattice_service_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpclattice_service_network_service_association) | resource |
| [aws_vpclattice_service_network_vpc_association.lattice_vpc_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpclattice_service_network_vpc_association) | resource |
| [aws_vpclattice_target_group.lambda_lattice_target_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpclattice_target_group) | resource |
| [aws_vpclattice_target_group.lattice_target_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpclattice_target_group) | resource |
| [aws_vpclattice_service.lattice_service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpclattice_service) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_service_network"></a> [service\_network](#input\_service\_network) | Amazon VPC Lattice Service Network information. You can either create a new Service Network or reference a current one (to associate Services or VPCs). The attribute `create_service_network` defines if you want to create or not a service network (`false` by default).<br>More information about the format of this variable can be found in the "Usage - Service Network" section of the README. | `any` | `{}` | no |
| <a name="input_services"></a> [services](#input\_services) | Definition of the VPC Lattice Services to create. You can use this module to either create only Lattice services (not associated with any service network), or associated with a service network (if you create one or provide an identifier). You can define 1 or more Service using this module.<br>More information about the format of this variable can be found in the "Usage - Services" section of the README. | `any` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all the resources created in this module. | `map(string)` | `{}` | no |
| <a name="input_target_groups"></a> [target\_groups](#input\_target\_groups) | Definitions of the Target Groups to create. You can define 1 or more Target Groups using this module.<br>More information about the format of this variable can be found in the "Usage - Target Groups" section of the README. | `any` | `{}` | no |
| <a name="input_vpc_associations"></a> [vpc\_associations](#input\_vpc\_associations) | VPC Lattice VPC associations. You can define 1 or more VPC associations using this module.<br>More information about the format of this variable can be found in the "Usage - VPC association" section of the README. | <pre>map(object({<br>    vpc_id             = optional(string)<br>    security_group_ids = optional(list(string))<br>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_listeners_by_service"></a> [listeners\_by\_service](#output\_listeners\_by\_service) | VPC Lattice Listener and Rules. Per Lattice Service, each Listener is composed by the following attributes:<br>- `attributes` = Full output of **aws\_vpclattice\_listener**.<br>- `rules`      = Full output of **aws\_vpclattice\_listener\_rule**. |
| <a name="output_service_network"></a> [service\_network](#output\_service\_network) | VPC Lattice resource attributes. Full output of **aws\_vpclattice\_service\_network**. |
| <a name="output_services"></a> [services](#output\_services) | VPC Lattice Services. The output is composed by the following attributes (per Service created):<br>- `attributes`                  = Full output of **aws\_vpclattice\_service**.<br>- `service_network_association` = Full output of **aws\_vpclattice\_service\_network\_service\_association**. |
| <a name="output_target_groups"></a> [target\_groups](#output\_target\_groups) | VPC Lattice Target Groups. Full output of **aws\_vpclattice\_target\_group**. |
| <a name="output_vpc_associations"></a> [vpc\_associations](#output\_vpc\_associations) | VPC Lattice VPC associations. Full output of **aws\_vpclattice\_service\_network\_vpc\_association**. |
<!-- END_TF_DOCS -->