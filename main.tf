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
  source  = "./modules/"

  cluster_name            = var.cluster_name
  cluster_domain          = var.cluster_domain
  cluster_version         = "1.3"
  master_instance_enabled = false
  warm_instance_enabled   = false
  hot_instance_type       = "t3.small.search"


  saml_entity_id        = var.saml_entity_id
  saml_metadata_content = data.http.saml_metadata.body
  saml_session_timeout  = 120
}
