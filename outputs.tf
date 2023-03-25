output "security_group" {
  description = "The AWS security group used to controll ingress traffic to the Client VPN self-service-portal."
  value       = module.sg
}

output "vpn" {
  description = "The Client VPN endpoint."
  value       = aws_ec2_client_vpn_endpoint.vpn
}

output "resolver_security_group" {
  description = "The AWS security group used to controll ingress traffic to the Route 53 DNS resolver endpoint."
  value       = module.resolver_sg
}

output "aws_route53_resolver_endpoint" {
  description = "The Route53 DNS resolver endpoint."
  value       = aws_route53_resolver_endpoint.vpn_dns
}
