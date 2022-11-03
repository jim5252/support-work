data "aws_region" "current" {}

data "http" "saml_metadata" {
  url = var.saml_metadata_url
  request_headers = {
    Accept = "application/xml"
  }
}

provider "elasticsearch" {
  url         = module.opensearch.cluster_endpoint
  aws_region  = data.aws_region.current.name
  healthcheck = false
}

module "opensearch" {
  source  = "idealo/opensearch/aws"
  version = "1.0.0"

  cluster_name          = var.cluster_name
  cluster_domain        = var.cluster_domain
  cluster_version       = "1.3"
  master_instance_count = 1
  master_instance_type  = "r6gd.large.elasticsearch"
  warm_instance_type    = "ultrawarm1.medium.elasticsearch"


  saml_entity_id        = var.saml_entity_id
  saml_metadata_content = data.http.saml_metadata.body
  saml_session_timeout  = 120
}
