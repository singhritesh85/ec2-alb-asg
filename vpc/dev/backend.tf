terraform {
  backend "s3" {
    bucket = "dolo-dempo"
    key    = "test/dev/terraform.tfstate"
    region = "us-east-2"
    encrypt = true
    dynamodb_table = "terraform-state"
  }
}

