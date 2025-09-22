# Terraform Aws Client Vpn Module
Terraform module to create an AWS Client VPN

[![blackbird-logo](https://raw.githubusercontent.com/blackbird-cloud/terraform-module-template/main/.config/logo_simple.png)](https://blackbird.cloud)

## Example
```hcl
module "client_vpn" {
    source  = "blackbird-cloud/client-vpn/aws"
    version = "~> 3.0"
    
    name                       = "example-client-vpn"
    
    cloudwatch_log_group_name  = var.cloudwatch_log_group_name
    cloudwatch_log_stream_name = var.cloudwatch_log_stream_name

    auth_rules                 = var.auth_rules

    client_cidr_block          = var.client_cidr_block
    vpc_id                     = var.vpc_id
    private_subnets            = var.private_subnets
    security_group_ids         = var.security_group_ids
    dns_servers                = var.dns_servers
    split_tunnel               = true
    server_certificate_arn     = var.server_certificate_arn
    vpn_saml_metadata           = file(var.vpn_saml_metadata_file)
    vpn_portal_saml_metadata    = file(var.vpn_portal_saml_metadata_file)
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.14.0 |

## Resources

| Name | Type |
|------|------|
| [aws_ec2_client_vpn_authorization_rule.auth](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_client_vpn_authorization_rule) | resource |
| [aws_ec2_client_vpn_authorization_rule.internet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_client_vpn_authorization_rule) | resource |
| [aws_ec2_client_vpn_endpoint.vpn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_client_vpn_endpoint) | resource |
| [aws_ec2_client_vpn_network_association.associations](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_client_vpn_network_association) | resource |
| [aws_ec2_client_vpn_route.internet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_client_vpn_route) | resource |
| [aws_ec2_client_vpn_route.routes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_client_vpn_route) | resource |
| [aws_iam_saml_provider.vpn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_saml_provider) | resource |
| [aws_iam_saml_provider.vpn_portal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_saml_provider) | resource |
| [aws_identitystore_group.sso_groups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/identitystore_group) | data source |
| [aws_ssoadmin_instances.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssoadmin_instances) | data source |
| [aws_vpc.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_auth_rules"></a> [auth\_rules](#input\_auth\_rules) | List of CIDR blocks, and IDP groups (SSO group IDs), or group names (AWS IAM Identity Center group names) to authorize access for. | <pre>list(object({<br/>    cidr        = string<br/>    groups      = optional(list(string), [])<br/>    group_names = optional(list(string), [])<br/>    description = string<br/>  }))</pre> | n/a | yes |
| <a name="input_client_cidr_block"></a> [client\_cidr\_block](#input\_client\_cidr\_block) | CIDR Block used for assigning IP's to clients, must not overlap with any of the connected networks. | `string` | n/a | yes |
| <a name="input_client_login_banner_text"></a> [client\_login\_banner\_text](#input\_client\_login\_banner\_text) | (Optional) The text to display on the client login banner. If not specified, no banner is displayed. | `string` | `""` | no |
| <a name="input_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#input\_cloudwatch\_log\_group\_name) | (Optional) CloudWatch log group name for VPN connection logging. | `string` | `""` | no |
| <a name="input_cloudwatch_log_stream_name"></a> [cloudwatch\_log\_stream\_name](#input\_cloudwatch\_log\_stream\_name) | (Optional) CloudWatch log stream name for VPN connection logging. | `string` | `""` | no |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | (Optional) Information about the DNS servers to be used for DNS resolution. A Client VPN endpoint can have up to two DNS servers. If no DNS server is specified, the DNS address of the connecting device is used. | `list(string)` | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the VPN | `string` | n/a | yes |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | List of private subnets | `list(string)` | n/a | yes |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | (Optional) List of security group IDs to associate with the Client VPN endpoint. If not specified, a new security group will be created. | `list(string)` | `[]` | no |
| <a name="input_server_certificate_arn"></a> [server\_certificate\_arn](#input\_server\_certificate\_arn) | ARN of the ACM certificate the server will use. | `string` | n/a | yes |
| <a name="input_split_tunnel"></a> [split\_tunnel](#input\_split\_tunnel) | To split the VPN tunnel, or not, defaults to false | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Map of resource tags for all AWS resources. If configured with a provider default\_tags configuration block present, tags with matching keys will overwrite those defined at the provider-level. | `map(string)` | `{}` | no |
| <a name="input_transport_protocol"></a> [transport\_protocol](#input\_transport\_protocol) | (Optional) The transport protocol to use for the VPN connection. Defaults to `tcp`. | `string` | `"tcp"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID For the VPN SG | `string` | n/a | yes |
| <a name="input_vpn_port"></a> [vpn\_port](#input\_vpn\_port) | (Optional) The port to use for the VPN connection. Defaults to `443`. | `number` | `443` | no |
| <a name="input_vpn_portal_saml_metadata"></a> [vpn\_portal\_saml\_metadata](#input\_vpn\_portal\_saml\_metadata) | VPN SelfService Portal XML document generated by an identity provider that supports SAML 2.0. | `string` | n/a | yes |
| <a name="input_vpn_saml_metadata"></a> [vpn\_saml\_metadata](#input\_vpn\_saml\_metadata) | VPN XML document generated by an identity provider that supports SAML 2.0. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vpn"></a> [vpn](#output\_vpn) | The Client VPN endpoint. |

## About

We are [Blackbird Cloud](https://blackbird.cloud), Amsterdam based cloud consultancy, and cloud management service provider. We help companies build secure, cost efficient, and scale-able solutions.

Checkout our other :point\_right: [terraform modules](https://registry.terraform.io/namespaces/blackbird-cloud)

## Copyright

Copyright © 2017-2025 [Blackbird Cloud](https://blackbird.cloud)