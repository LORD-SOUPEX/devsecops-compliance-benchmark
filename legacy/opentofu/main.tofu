terraform {
  required_providers {
    aws = { source = "hashicorp/aws"
    version = "~> 5.0" }
  }
}

resource "aws_ebs_volume" "scratch" {
availability_zone = "eu-west-3a"
  size = 500
  encrypted = false
}

resource "aws_db_instance" "legacy" {
  allocated_storage    = 20
  engine               = "mysql"
  instance_class       = "db.t3.micro"
  username             = "admin"
  password             = "admin123"
  publicly_accessible  = true
  storage_encrypted    = false
  skip_final_snapshot  = true
}
