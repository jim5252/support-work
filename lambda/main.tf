module "lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version =  "4.7.1"

  source_path = "../lambda/s3-decompressor.py"
  create_role =  true
  handler = "s3-decompressor.lambda_handler"
  runtime = "python3.7"
  timeout = 30

}
