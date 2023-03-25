data "aws_vpc" "selected" {
  id = var.vpc_id
}

locals {
  vpc_cidr_block = data.aws_vpc.selected.cidr_block
  routes = distinct(compact([
    for auth_rule in var.auth_rules : auth_rule.cidr != local.vpc_cidr_block ? auth_rule.cidr : null
  ]))
  routes_per_subnet = toset(
    flatten(
      [
        for subnet_id in var.private_subnets : [
          for route in local.routes : {
            subnet_id = subnet_id
            route     = route
          }
        ]
      ]
    )
  )
  auth_rules = toset(
    flatten(
      [
        for auth_rule in var.auth_rules : [
          for group in auth_rule.groups : {
            description = auth_rule.description
            cidr        = auth_rule.cidr
            group       = group
          }
        ]
      ]
    )
  )
}

module "sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.17.1"

  vpc_id      = var.vpc_id
  name        = "${var.name}-sg"
  description = "Security group for ${var.name} VPN"
  ingress_with_cidr_blocks = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Client VPN"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Client VPN"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  tags = var.tags
}

resource "aws_iam_saml_provider" "vpn" {
  name                   = "${var.name}-vpn"
  saml_metadata_document = var.vpn_saml_metadata
  tags                   = var.tags
}

resource "aws_iam_saml_provider" "vpn_portal" {
  name                   = "${var.name}-vpn-portal"
  saml_metadata_document = var.vpn_portal_saml_metadata
  tags                   = var.tags
}

# https://aws.amazon.com/blogs/security/authenticate-aws-client-vpn-users-with-aws-single-sign-on/
resource "aws_ec2_client_vpn_endpoint" "vpn" {
  description            = var.name
  server_certificate_arn = var.server_certificate_arn
  client_cidr_block      = var.client_cidr_block
  self_service_portal    = "enabled"
  split_tunnel           = var.split_tunnel
  transport_protocol     = "tcp"

  authentication_options {
    type                           = "federated-authentication"
    saml_provider_arn              = aws_iam_saml_provider.vpn.arn
    self_service_saml_provider_arn = aws_iam_saml_provider.vpn_portal.arn
  }

  connection_log_options {
    enabled               = var.cloudwatch_log_group_name != "" && var.cloudwatch_log_stream_name != ""
    cloudwatch_log_group  = var.cloudwatch_log_group_name
    cloudwatch_log_stream = var.cloudwatch_log_stream_name
  }

  dns_servers = concat(var.dns_servers, [
    for ip_address in aws_route53_resolver_endpoint.vpn_dns.ip_address : ip_address.ip
  ])
  security_group_ids = [module.sg.security_group_id]
  vpc_id             = var.vpc_id

  tags = var.tags
}

resource "aws_ec2_client_vpn_network_association" "associations" {
  for_each = toset(var.private_subnets)

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn.id
  subnet_id              = each.key
}

resource "aws_ec2_client_vpn_route" "routes" {
  for_each = {
    for route_per_subnet in local.routes_per_subnet : "${route_per_subnet.route}-${route_per_subnet.subnet_id}" => route_per_subnet
  }

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn.id
  destination_cidr_block = each.value.route
  target_vpc_subnet_id   = each.value.subnet_id
}

locals {
  internet_private_subnets = var.split_tunnel ? [] : var.private_subnets
}

resource "aws_ec2_client_vpn_route" "internet" {
  for_each = {
    for subnet in local.internet_private_subnets : subnet => subnet
  }

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn.id
  destination_cidr_block = "0.0.0.0/0"
  target_vpc_subnet_id   = each.key
}

resource "aws_ec2_client_vpn_authorization_rule" "auth" {
  depends_on = [aws_ec2_client_vpn_network_association.associations]
  for_each = {
    for rule in local.auth_rules : "${rule.cidr}-${rule.group}" => rule
  }

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn.id
  target_network_cidr    = each.value.cidr
  access_group_id        = each.value.group
  description            = each.value.description
}

resource "aws_ec2_client_vpn_authorization_rule" "internet" {
  count = var.split_tunnel ? 0 : 1

  authorize_all_groups   = true
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn.id
  target_network_cidr    = "0.0.0.0/0"
  description            = "internet"
}

module "resolver_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.17.1"

  vpc_id      = var.vpc_id
  name        = "${var.name}-dns-resolver"
  description = "Security group for ${var.name} VPN"
  ingress_with_cidr_blocks = [
    {
      from_port   = 53
      to_port     = 53
      protocol    = "tcp"
      description = "DNS TCP"
      cidr_blocks = "${var.client_cidr_block},${local.vpc_cidr_block}"
    },
    {
      from_port   = 53
      to_port     = 53
      protocol    = "udp"
      description = "DNS UDP"
      cidr_blocks = "${var.client_cidr_block},${local.vpc_cidr_block}"
    }
  ]
  tags = var.tags
}

# https://aws.amazon.com/premiumsupport/knowledge-center/client-vpn-how-dns-works-with-endpoint/
# https://docs.aws.amazon.com/vpn/latest/clientvpn-user/linux-troubleshooting.html
resource "aws_route53_resolver_endpoint" "vpn_dns" {
  name               = "${var.name}-dns-resolver"
  direction          = "INBOUND"
  security_group_ids = [module.resolver_sg.security_group_id]

  dynamic "ip_address" {
    for_each = { for subnet in var.private_subnets : subnet => subnet }
    content {
      subnet_id = ip_address.value
    }
  }
}
