terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }

  backend "s3" {
    bucket = "at32test"         # pre-created backend bucket
    key    = "angeline.tfstate" # unique path per workspace/repo
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}

locals {
  # ✅ HCL2 expressions (no interpolation-only strings)
  name_prefix = split("/", data.aws_caller_identity.current.arn)[1]
  account_id  = data.aws_caller_identity.current.account_id
}

resource "aws_s3_bucket" "s3_tf" {
  # Mixing literals + ${...} is fine. The deprecation only applies when the
  # ENTIRE value is a single "${ ... }" expression.
  bucket = "${local.name_prefix}-s3-tf-bkt-${local.account_id}"

  tags = {
    Name        = "tf-ci-demo"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
