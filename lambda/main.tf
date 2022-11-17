locals {
  policy_name = "lambda_role"
}

data "archive_file" "decompress_object" {
  type        = "zip"
  source_file = "${path.module}/../lambda/s3-decompressor.py"
  output_path = "${path.module}/lambda/s3-decompressor.zip"
}

module "lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version =  "4.7.1"

  source_path = data.archive_file.decompress_object.output_path
  create_role =  true
  policy_name = "lambda-role"
  handler = "s3-decompressor.lambda_handler"
  runtime = "python3.7"
  timeout = 30
  function_name = "decompress-object"

}
