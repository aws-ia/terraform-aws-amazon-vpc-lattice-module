<!-- BEGIN_TF_DOCS -->
# Amazon VPC Lattice Module

This module can be used to deploy resources from [Amazon VPC Lattice](https://docs.aws.amazon.com/vpc-lattice/latest/ug/what-is-vpc-service-network.html). VPC Lattice is a fully managed application networking service that you use to connect, secure, and monitor all your services across multiple accounts and virtual private clouds (VPCs).

This module handles all the different resources you can use with VPC Lattice: Service Network, Service, Listeners, Listener Rules, Target Groups (and targets), and Associations (Service or VPC). You have the freedom to create the combination of resources you need, so in multi-AWS Account environments you can make use of the module as many times as needed (different providers) to create your application network architecture.

## Usage

### VPC Lattice service network (var.service\_network)

A [VPC Lattice service network](https://docs.aws.amazon.com/vpc-lattice/latest/ug/service-networks.html) is a logical boundary for a collection of services. It is the central place of connectivity where consumers (located in a VPC) and producers (target groups) are connected to allow service consumption. In addition, it provides a central place for access control via [IAM auth policies](https://docs.aws.amazon.com/vpc-lattice/latest/ug/auth-policies.html), and visibility by enabling [logs](https://docs.aws.amazon.com/vpc-lattice/latest/ug/monitoring-access-logs.html).

When creating a service network in the module, the following attributes are expected:

- `name`                  = (Optional|string) VPC Lattice service network name. This attribute creates a **new** service network using the specified name. **This attribute and `identifier` cannot be set at the same time.**
- `auth_type`             = (Optional|string) Type of IAM policy to apply in the service network. Allowed values are `NONE` (default) and `AWS_IAM`.
- `auth_policy`           = (Optional|any) Auth policy. The policy string in JSON must not contain newlines or blank lines. The auth policy resource will be created only if `auth_type` is set to `AWS_IAM`.
- `identifier`            = (Optional|string) The ID or ARN of an **existing** service network. If you are working in multi-AWS account environments, ARN is compulsory. **This attribute and `name` cannot be set at the same time.**
- `access_log_cloudwatch` = (Optional|string) Amazon CloudWatch log group ARN to configure as service network's access log destination.
- `access_log_s3`         = (Optional|string) Amazon S3 bucket ARN to configure as service network's access log destination.
- `access_log_firehose`   = (Optional|string) Data Firehose delivery stream ARN to configure as service network's access log destination.

You can share VPC Lattice service networks using AWS RAM with this module. Check the section [Sharing VPC Lattice resources](#sharing-vpc-lattice-resources) for more information.

**Examples** of use can be found in the [/examples/service\_network](./examples/service\_network/) folder.

#### VPC associations (var.vpc\_associations)

When you associate a VPC with a service network, it enables all the resources within that VPC to be clients and communicate with other services associated to that same service network. You can make use of Security Groups to control the access of the VPC association, allowing some traffic segmentation before the traffic arrives to the Service Network.

You can create more than 1 VPC association with this module, as this variable expects a map of objects with the following attributes:

- `vpc_id`             = (string) ID of the VPC.
- `security_group_ids` = (Optional|list(string)) List of Security Group IDs to associate with the VPC association.

#### Access Logs for VPC Lattice service networks

You can enable [access logs](https://docs.aws.amazon.com/vpc-lattice/latest/ug/service-network-monitoring.html) for VPC Lattice service networks and specify the destination resource for your logs. VPC Lattice can send logs to the following resources: **CloudWatch Log groups**, **Firehose delivery streams**, and **S3 buckets**. You can configure the three destinations at the same time (`access_log_cloudwatch`, `access_log_s3`, `access_log_firehose`), but you cannot configure the same destination type twice.

### VPC Lattice service (var.services)

A [VPC Lattice service](https://docs.aws.amazon.com/vpc-lattice/latest/ug/services.html) is an independently deployable unit of software that delivers a specific task or function. It can run on instances, containers, or as serverless functions within an AWS Account or a VPC. A service has a [listener](https://docs.aws.amazon.com/vpc-lattice/latest/ug/listeners.html) that uses **rules** you can configure to help route traffic to your targets.

You can create 1 or more VPC Lattice services using the module, as this variable expects a **map of objects** with the following attributes:

- `identifier`            = (Optional|string) ID or ARN of the VPC Lattice service (if it was created outside this module). **This attribute and `name` cannot be set at the same time.**
- `name`                  = (Optional|string) VPC Lattice service's name - to create a new resource. **This attribute and `identifier` cannot be set at the same time.**
- `auth_type`             = (Optional|string) Type of IAM policy. Either `NONE` (default) or `AWS_IAM`.
- `auth_policy`           = (Optional|any) Auth policy. The policy string in JSON must not contain newlines or blank lines. The auth policy resource will be created only if `auth_type` is set to `AWS_IAM`.
- `certificate_arn`       = (Optional|string) **When configuring a HTTPS listener** AWS Certificate Manager certificate's ARN.
- `custom_domain_name`    = (Optional|string) Custom domain name for the service.
- `listeners`             = (Optional|map(string)) VPC Lattice listeners (and rules) to configure in the service - more information about its definition below.
- `hosted_zone_id`        = (Optional|string) Amazon Route 53 hosted zone ID to configure Alias records when configuring custom domain names. Check the section [Amazon Route 53 DNS configuration](#amazon-route-53-dns-configuration) for more information.
- `access_log_cloudwatch` = (Optional|string) Amazon CloudWatch log group ARN to configure as service network's access log destination.
- `access_log_s3`         = (Optional|string) Amazon S3 bucket ARN to configure as service network's access log destination.
- `access_log_firehose`   = (Optional|string) Data Firehose delivery stream ARN to configure as service network's access log destination.

The attribute `listeners` (you can define 1 or more) supports the following:

- `name`           = (Optional|string) Listener's name. If this attribute is not defined, the key will be used as name.
- `port`           = (Optional|number) Listener's port. You can specify a value from 1 to 65535. If not defined, the default values are 80 for `HTTP` and 443 for `HTTPS`.
- `protocol`       = (string) Listener's protocol.
- `default_action` = (map(any)) Default action block for the default listener rule - more information about its definition below.
- `rules`          = (Optional|any) Rules to define in a listener to determine how the service routes requests to its registered targets - more information about its definition below.

The attribute `default_action` *- map(any) -* supports the following:

- `type`          = (string) Default action to apply in the listener. Allowed values are `fixed_response` and `forward`.
- `status_code`   = (Optional|number) Custom HTTP status codd to return. **To define if the default\_action type is `fixed-response`**.
- `target_groups` = (Optional|map(string)) Map of target groups to use in the listener's default action. **To define if the default\_action type is `forward`**. The map expects the following:
  - `target_group_identifier` = (string) Target group identifier. **The key of each target group should map the key you defined in var.target\_groups**.
  - `weight`                  = (Optional|number) Determines how requests are distributed to the target group. Only required if you specify multiple target groups for a forward action.

The attribute `rules` (you can define 1 or more) supports the following:

- `name` = (Optional|string)Listener Rule's name. If not defined, the key will be use as name.
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

You can share VPC Lattice services using AWS RAM with this module. Check the section [Sharing VPC Lattice resources](#sharing-vpc-lattice-resources) for more information.

**Examples** of use can be found in the [/examples/service](./examples/service/) folder. Note that all the target groups used in the examples will be empty. In the [Target groups](#target-groups-vartarget\_groups) section you will find more information about how to define the different target types.

#### VPC Lattice service associations

When a VPC Lattice service network is created or referenced using the module, a [VPC Lattice service association](https://docs.aws.amazon.com/vpc-lattice/latest/ug/service-associations.html) is created automatically for each VPC Lattice service created/referenced in the module.

#### Access Logs for VPC Lattice services

You can enable [access logs](https://docs.aws.amazon.com/vpc-lattice/latest/ug/service-monitoring.html) for VPC Lattice services and specify the destination resource for your logs. VPC Lattice can send logs to the following resources: **CloudWatch Log groups**, **Firehose delivery streams**, and **S3 buckets**. You can configure the three destinations at the same time (`access_log_cloudwatch`, `access_log_s3`, `access_log_firehose`) for each VPC Lattice service configured under `var.services`, but you cannot configure the same destination type twice.

### Target Groups (var.target\_groups)

A [Target group](https://docs.aws.amazon.com/vpc-lattice/latest/ug/target-groups.html) is a collection of targets, or compute resources that run your application or service. Targets in VPC Lattice can be Amazon EC2 instances, IP addresses, AWS Lambda functions, Application Load Balancers, Amazon ECS tasks or Kubernetes Pods.

You can create 1 or more target groups with this module, as this variable expects a **map of objects** with the following attributes:

- `name`         = (Optional|string) Target group's name. If not provided, the key of the map will be used as name.
- `type`         = (string) The type of target group. Valid Values are `IP`, `LAMBDA`, `INSTANCE`, `ALB`.
- `config`       = (Optional|map(any)) Target group configuration - more information about its definition below. If type is set to `LAMBDA`, this parameter should not be specified.
- `health_check` = (Optional|map(any)) Health check configuration - more information about its definition below. If type is set to `LAMBDA` or `ALB`, this parameter should not be specified.
- `targets`      = (Optional|map(any)) Targets to associate to the target group. If `type` is equals to `LAMBDA` or `ALB`, only one target can be defined. More information about its definition below.

**The key used for each of the target group definitions is the one expected when defining the listeners and rules (var.services)**, so make sure these values are unique.

The `config` attribute *- map(any) -* supports the following:

- `port`                           = (number) Port on which the targets are listening. Not supported if type is set to `LAMBDA`.
- `protocol`                       = (string) Protocol to use for routing traffic to the targets. Valid values: `HTTP` and `HTTPS`. Not supported if type is set to `LAMBDA`.
- `vpc_identifier`                 = (string) VPC ID. Not supported if type is set to `LAMBDA`.
- `ip_address_type`                = (Optional|string) IP address type for the target group. Valid values: `IPV4` and `IPV6`. Not supported if type is set to `LAMBDA` or `ALB`.
- `protocol_version`               = (Optional|string) Protocol version. Valid values: `HTTP1` (default), `HTTP2`, `GRPC`. Not supported if type is set to `LAMBDA`.
- `lambda_event_structure_version` = (Optional|string) The version of the event structure that the Lambda function receives. Valid values: `V1`and `V2` (default). Supported only if type is set to `LAMBDA`.

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

**Examples** of use can be found in the [/examples/target\_groups](./examples/target\_groups/) folder. You will find an example for each target supported in this module.

### Sharing VPC Lattice resources (var.ram\_share)

With [AWS Resource Access Manager](https://aws.amazon.com/ram/) (RAM), you can share VPC Lattice service networks and services. With this module, you can use the variable `var.ram_share` to share VPC Lattice resources. The variable supports the following attributes:

- `resources_share_arn`       = (Optional|string) ARN of an **existing** RAM Resource Share to use to associate principals and VPC Lattice resources. **This attribute and `resource_share_name` cannot be set at the same time.**
- `resources_share_name`      = (Optional|string) Name of the RAM Resource Share resource. This attribute creates a **new** resource using the specified name. **This attribute and `resources_share_arn` cannot be set at the same time.**
- `allow_external_principals` = (Optional|boolean) Indicates whether principals outside your organization can be associated with a resource share. **This attribute is allowed only when `resources_share_name` is provided.**
- `principals`                = (Optional|list(string)) List of AWS principals to associated the resources with. Possible values are an AWS account ID, an AWS Organizations Organization ARN, or an AWS Organizations Organization Unit ARN.
- `share_service_network`     = (Optional|boolean) Indicates whether a created VPC Lattice service network should be associated or not. Defaults to `true`.
- `share_services`            = (Optional|list(string)) List of created VPC Lattice services to share. You should use the services' keys defined in `var.services`.

**Examples** of use can be found in the [/examples/ram\_share](./examples/ram\_share/) folder.

### Amazon Route 53 DNS configuration

VPC Lattice leverages [Domain Name System (DNS)](https://aws.amazon.com/route53/what-is-dns/) for service discovery, so each VPC Lattice service is easily identifiable through its service-managed or custom domain names. When a new Amazon VPC Lattice service is created, a service-managed domain name is generated. This domain name is publicly resolvable and resolves either to an IPv4 link-local address or an IPv6 unique-local address. So, a consumer application using this service-managed domain name does not require any extra DNS configuration for the service-to-service communication (provided the VPC Lattice configuration allows connectivity). However, it’s more likely that you will use your own custom domain names.

When using custom domain names for Amazon VPC Lattice services, an [alias](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/ResourceRecordTypes.html) (for Amazon Route 53 hosted zones) have to be created to map the custom domain name with the service-managed domain name. In multi-service environments, the creation of the DNS resolution configuration can create heavy operational overhead.

This module supports the creation of alias records (both A and AAAA) in Route 53 hosted zones specified in two locations:

- By using the variable `var.dns_configuration` (Optional|map(string)), you can specify a "global" hosted zone ID (attribute `hosted_zone_id`) to configure the Alias record of each VPC Lattice service created/referenced with a custom domain name configured.
- By using the attribute `hosted_zone_id` under each VPC Lattice service configured (`var.services`) you can create the Alias record for the provided Hosted Zone ID only for that specific service.
- A Hosted Zone ID referenced in a service definition overrides the configuration done in `var.dns_configuration`.

**The module only supports the DNS configuration if the Hosted Zone and VPC Lattice service are in the same AWS Account**. For multi-Account environments, please check the [Guidance for Amazon VPC Lattice Automated DNS Configuration on AWS](https://aws.amazon.com/solutions/guidance/amazon-vpc-lattice-automated-dns-configuration-on-aws/). This Guidance Solution follows an event-driven architecture to communicate AWS Accounts and configure DNS records when Hosted Zones and VPC Lattice services are in different AWS Accounts.

**Examples** of use can be found in the [/examples/dns\_configuration](./examples/dns\_configuration/) folder.

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
| <a name="module_tags"></a> [tags](#module\_tags) | aws-ia/label/aws | 0.0.6 |
| <a name="module_targets"></a> [targets](#module\_targets) | ./modules/targets | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_ram_principal_association.ram_principal_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_principal_association) | resource |
| [aws_ram_resource_association.ram_service_network_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_association) | resource |
| [aws_ram_resource_association.ram_services_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_association) | resource |
| [aws_ram_resource_share.ram_resource_share](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_share) | resource |
| [aws_route53_record.custom_domain_name_a_record](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.custom_domain_name_aaaa_record](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_vpclattice_access_log_subscription.service_cloudwatch_access_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpclattice_access_log_subscription) | resource |
| [aws_vpclattice_access_log_subscription.service_firehose_access_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpclattice_access_log_subscription) | resource |
| [aws_vpclattice_access_log_subscription.service_network_cloudwatch_access_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpclattice_access_log_subscription) | resource |
| [aws_vpclattice_access_log_subscription.service_network_firehose_access_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpclattice_access_log_subscription) | resource |
| [aws_vpclattice_access_log_subscription.service_network_s3_access_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpclattice_access_log_subscription) | resource |
| [aws_vpclattice_access_log_subscription.service_s3_access_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpclattice_access_log_subscription) | resource |
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
| <a name="input_dns_configuration"></a> [dns\_configuration](#input\_dns\_configuration) | Amazon Route 53 DNS configuration. For VPC Lattice services with custom domain name configured, you can indicate the Hosted Zone ID to create the corresponding Alias record (IPv4 and IPv6) pointing to the VPC Lattice-generated domain name.<br>You can override the Hosted Zone to configure the Alias record by configuring the `hosted_zone_id` attribute under each service definition (`var.services`). <br>This configuration is only supported if both the VPC Lattice service and the Route 53 Hosted Zone are in the same account. More information about the variable format and multi-Account support can be found in the "Amazon Route 53 DNS configuration" section of the README. | `map(string)` | `{}` | no |
| <a name="input_ram_share"></a> [ram\_share](#input\_ram\_share) | Configuration of the resources to share using AWS Resource Access Manager (RAM). VPC Lattice service networks and services can be shared using RAM.<br>More information about the format of this variable can be found in the "Sharing VPC Lattice resources" section of the README. | `any` | `{}` | no |
| <a name="input_service_network"></a> [service\_network](#input\_service\_network) | Amazon VPC Lattice service network information. You can either create a new service network or reference a current one (to associate VPC Lattice services or VPCs). Setting the `name` attribute will create a **new** service network, while using the attribute `identifier` will reference an **existing** service network.<br>More information about the format of this variable can be found in the "Usage - VPC Lattice service network" section of the README. | `any` | `{}` | no |
| <a name="input_services"></a> [services](#input\_services) | Definition of the VPC Lattice Services to create. You can use this module to either create only Lattice services (not associated with any service network), or associated with a service network (if you create one or provide an identifier). You can define 1 or more Service using this module.<br>More information about the format of this variable can be found in the "Usage - VPC Lattice service" section of the README. | `any` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all the resources created in this module. | `map(string)` | `{}` | no |
| <a name="input_target_groups"></a> [target\_groups](#input\_target\_groups) | Definitions of the Target Groups to create. You can define 1 or more Target Groups using this module.<br>More information about the format of this variable can be found in the "Usage - Target Groups" section of the README. | `any` | `{}` | no |
| <a name="input_vpc_associations"></a> [vpc\_associations](#input\_vpc\_associations) | VPC Lattice VPC associations. You can define 1 or more VPC associations using this module.<br>More information about the format of this variable can be found in the "Usage - VPC association" section of the README. | <pre>map(object({<br>    vpc_id             = optional(string)<br>    security_group_ids = optional(list(string))<br>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_listeners_by_service"></a> [listeners\_by\_service](#output\_listeners\_by\_service) | VPC Lattice Listener and Rules. Per Lattice Service, each Listener is composed by the following attributes:<br>- `attributes` = Full output of **aws\_vpclattice\_listener**.<br>- `rules`      = Full output of **aws\_vpclattice\_listener\_rule**. |
| <a name="output_ram_resource_share"></a> [ram\_resource\_share](#output\_ram\_resource\_share) | AWS Resource Access Manager resource share. Full output of **aws\_ram\_resource\_share**. |
| <a name="output_service_network"></a> [service\_network](#output\_service\_network) | VPC Lattice resource attributes. Full output of **aws\_vpclattice\_service\_network**. |
| <a name="output_service_network_log_subscriptions"></a> [service\_network\_log\_subscriptions](#output\_service\_network\_log\_subscriptions) | VPC Lattice service network access log subscriptions. The output is composed by the following attributes:<br>- `cloudwatch` = Full output of **aws\_vpclattice\_access\_log\_subscription**.<br>- `s3`         = Full output of **aws\_vpclattice\_access\_log\_subscription**.<br>- `firehose`   = Full output of **aws\_vpclattice\_access\_log\_subscription**. |
| <a name="output_services"></a> [services](#output\_services) | VPC Lattice Services. The output is composed by the following attributes (per Service created):<br>- `attributes`                  = Full output of **aws\_vpclattice\_service**.<br>- `service_network_association` = Full output of **aws\_vpclattice\_service\_network\_service\_association**.<br>- `log_subscriptions`           = *The output is composed by the following attributes:*<br>  - `cloudwatch` = Full output of **aws\_vpclattice\_access\_log\_subscription**.<br>  - `s3`         = Full output of **aws\_vpclattice\_access\_log\_subscription**.<br>  - `firehose`   = Full output of **aws\_vpclattice\_access\_log\_subscription**. |
| <a name="output_target_groups"></a> [target\_groups](#output\_target\_groups) | VPC Lattice Target Groups. Full output of **aws\_vpclattice\_target\_group**. |
| <a name="output_vpc_associations"></a> [vpc\_associations](#output\_vpc\_associations) | VPC Lattice VPC associations. Full output of **aws\_vpclattice\_service\_network\_vpc\_association**. |
<!-- END_TF_DOCS -->