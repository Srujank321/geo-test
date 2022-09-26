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

resource "aws_instance" "geo-testserver" {
  ami           = "ami-830c94e3"
  instance_type = "t3.nano"

  tags = {
    Name = "geo-testserver"
  }
}
