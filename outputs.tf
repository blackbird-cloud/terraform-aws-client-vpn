output "security_group" {
  value = module.sg
}

# output "vpc" {
#   value = module.vpc
# }

output "vpn" {
  value = aws_ec2_client_vpn_endpoint.vpn
}
