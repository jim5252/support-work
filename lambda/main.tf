locals {
  policy_name = "lambda_role"
}

module "lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version =  "4.7.1"

  source_path = "${path.module}/../config/s3-decompressor.py"
  create_role =  true
  policy_name = "lambda-role"
  handler = "s3-decompressor.lambda_handler"
  runtime = "python3.7"
  timeout = 30
  function_name = "decompress-object"

}
