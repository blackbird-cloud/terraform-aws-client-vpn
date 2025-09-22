variable "vpc_id" {
    description = "VPC ID where the Client VPN endpoint will be created"
    type        = string
}

variable "subnet_ids" {
    description = "List of subnet IDs to associate with the Client VPN endpoint"
    type        = list(string)
}

variable "client_cidr_block" {
    description = "CIDR block for client IP addresses"
    type        = string
    default     = "10.0.0.0/16"
}

variable "server_certificate_arn" {
    description = "ARN of the server certificate"
    type        = string
}

variable "client_certificate_arn" {
    description = "ARN of the client certificate"
    type        = string
}

variable "name" {
    description = "Name prefix for resources"
    type        = string
    default     = "client-vpn"
}

variable "tags" {
    description = "Tags to apply to resources"
    type        = map(string)
    default     = {}
}

variable "cloudwatch_log_group_name" {
    description = "Name of the CloudWatch log group for Client VPN logs"
    type        = string
    default     = null
}

variable "cloudwatch_log_stream_name" {
    description = "Name of the CloudWatch log stream for Client VPN logs"
    type        = string
    default     = null
}

variable "auth_rules" {
  type = list(object({
    cidr        = string
    groups      = optional(list(string), [])
    group_names = optional(list(string), [])
    description = string
  }))
  description = "List of CIDR blocks, and IDP groups (SSO group IDs), or group names (AWS IAM Identity Center group names) to authorize access for."
}

variable "private_subnets" {
    description = "List of private subnet IDs to associate with the Client VPN endpoint"
    type        = list(string)
}

variable "security_group_ids" {
    description = "List of security group IDs to associate with the Client VPN endpoint"
    type        = list(string)
    default     = []
}

variable "dns_servers" {
    description = "List of DNS server IP addresses"
    type        = list(string)
    default     = []
}

variable "vpn_saml_metadata_file" {
    description = "Path to the SAML metadata file for VPN authentication"
    type        = string
}

variable "vpn_portal_saml_metadata_file" {
    description = "Path to the SAML metadata file for VPN portal authentication"
    type        = string
}

