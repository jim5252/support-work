resource "elasticsearch_index_template" "index_template" {
  for_each = var.index_templates

  name = each.key
  body = jsonencode(each.value)

  depends_on = [elasticsearch_opendistro_roles_mapping.master_user_arn]
}
