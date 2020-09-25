provider "aws" {
  region  = "ap-northeast-1"
  profile = "ded-aws"
}

terraform {
  backend "s3" {
    bucket  = "ds-backend-lt-demo-tfstate"
    profile = "ded-aws"
    key     = "terraform.tfstate"
    encrypt = true
  }
}