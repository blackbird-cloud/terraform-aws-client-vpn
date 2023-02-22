output "security_group" {
  value = module.sg
}

output "vpn" {
  value = aws_ec2_client_vpn_endpoint.vpn
}
