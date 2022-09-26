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

resource "aws_route53_zone" "geo" {
  name = "geo-terraform-test.com"

  tags = {
    Name = "tets-geo"
  }
}

resource "aws_route53_record" "test-geo" {
  zone_id = aws_route53_zone.geo.zone_id
  name    = "instance-test.geo-terraform-test.com"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.geo-testserver.private_ip]
}