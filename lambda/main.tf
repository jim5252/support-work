module "lambda" {
  source  = "terraform-aws-modules/terraform-aws-lambda"
  version =  "4.7.1"

  source_path = "../lambda/s3-decompressor.py"

}
