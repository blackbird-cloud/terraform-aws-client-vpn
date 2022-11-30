module "sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.8.0"

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
}
