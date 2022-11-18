output "cluster_name" {
  description = "The name of the OpenSearch cluster."
  value       = aws_opensearch_domain.opensearch.domain_name
}

output "cluster_version" {
  description = "The version of the OpenSearch cluster."
  value       = replace(aws_opensearch_domain.opensearch.engine_version, "OpenSearch_", "")
}

output "cluster_endpoint" {
  description = "The endpoint URL of the OpenSearch cluster."
  value       = "https://${aws_opensearch_domain.opensearch.domain_endpoint_options[0].custom_endpoint}"
}

output "kibana_endpoint" {
  description = "The endpoint URL of the OpenSearch dashboards."
  value       = "https://${aws_opensearch_domain.opensearch.domain_endpoint_options[0].custom_endpoint}/_dashboards/"
}
