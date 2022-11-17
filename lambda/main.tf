module "lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version =  "4.7.1"

  source_path = "../lambda/s3-decompressor.py"

}
