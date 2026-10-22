terraform {
required_providers {
aws = {
source = "hashicorp/aws"
version="~> 5.0"
}
}
}

provider "aws" {
  region     = "eu-west-3"
}

variable "unused_flag" {
}

variable "bucket" {
  default = "legacy-public-reports"
}

# Public, unencrypted, unversioned bucket: Checkov must flag it.
resource "aws_s3_bucket" "reports" {
  bucket = "${var.bucket}"
  acl    = "public-read"
}

resource "aws_security_group" "everything_open" {
  name        = "legacy-open"
  description = "temporary hack from 2019"

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}

resource "aws_instance" "pet" {
  ami           = "ami-0123456789abcdef0"
  instance_type = "t1.micro"
  associate_public_ip_address = true
  user_data = "export DB_PASSWORD=hunter2"
}
