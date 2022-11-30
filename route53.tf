# https://aws.amazon.com/premiumsupport/knowledge-center/client-vpn-how-dns-works-with-endpoint/
# https://docs.aws.amazon.com/vpn/latest/clientvpn-user/linux-troubleshooting.html

resource "aws_route53_resolver_endpoint" "vpn_dns" {
  name               = "${var.name}-dns-access"
  direction          = "INBOUND"
  security_group_ids = [module.sg.security_group_id]

  dynamic "ip_address" {
    for_each = { for subnet in var.private_subnets : subnet => subnet }
    content {
      subnet_id = ip_address.value
    }
  }
}
