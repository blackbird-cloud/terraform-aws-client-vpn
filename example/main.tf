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