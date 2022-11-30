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
