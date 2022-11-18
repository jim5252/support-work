locals {
  policy_name = "lambda_role"
}

module "lambda" {
  source  = "cloudposse/lambda-function/aws"
  version =  "0.4.1"

  filename = "${path.module}/config/s3-decompressor.py"
  handler = "s3-decompressor.lambda_handler"
  runtime = "python3.7"
  timeout = 30
  function_name = "decompress-object"

}
