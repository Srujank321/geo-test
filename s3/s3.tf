terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "ap-southeast-1"
}

resource "aws_kms_key" "testkey" {
  description             = "This key is used to encrypt bucket objects"
}

resource "aws_s3_bucket" "testbucket" {
  bucket = "testbucket"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "test" {
  bucket = aws_s3_bucket.testbucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.testkey.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

data "aws_iam_policy_document" {
  statement {
    principals {
      type  = "AWS"
      value = "arn:aws:iam::AccountA-ID:user/test"
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.testbucket.arn,
      "${aws_s3_bucket.testbucket.arn}/*",
    ]
  }
}

data "aws_iam_policy_document" {
  statement {
    principals {
      type  = "AWS"
      value = "arn:aws:iam::AccountA-ID:root"
    actions = [
      "s3:*"
    ]

    resources = [
      aws_s3_bucket.testbucket.arn,
      "${aws_s3_bucket.testbucket.arn}/*"
    ]
  }
}
}
