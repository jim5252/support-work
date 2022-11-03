variable "cluster_name" {
  description = "The name of the OpenSearch cluster."
  type        = string
  default     = "opensearch"
}

variable "cluster_domain" {
  description = "The hosted zone name of the OpenSearch cluster."
  type        = string
}

variable "saml_entity_id" {
  description = "The unique Entity ID of the application in SAML Identity Provider."
  type        = string
}

variable "saml_metadata_url" {
  description = "The URL of the SAML Identity Provider's metadata xml."
  type        = string
}

variable "hot_instance_type" {
  description = "The type of EC2 instances to run for each hot node. A list of available instance types can you find at https://aws.amazon.com/en/opensearch-service/pricing/#On-Demand_instance_pricing"
  type        = string
  default     = "r6gd.4xlarge.elasticsearch"

  validation {
    condition     = can(regex("^[m3|r3|i3|i2|r6gd|t3]", var.hot_instance_type))
    error_message = "The EC2 hot_instance_type must provide a SSD or NVMe-based local storage."
  }
}
