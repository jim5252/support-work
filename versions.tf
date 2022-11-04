terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.9"
    }
    elasticsearch = {
      source  = "phillbaker/elasticsearch"
      version = "2.0.0"
    }
  }
}
