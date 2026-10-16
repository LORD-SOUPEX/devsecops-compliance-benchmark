terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "environment" {
  type        = string
  description = "Target deployment environment"
  default     = "staging"
}

variable "instance_type" {
  type        = string
  description = "EC2 compute instance type"
  default     = "t3.micro"
}

resource "aws_ebs_volume" "persistent_storage" {
  availability_zone = "eu-west-3a"
  size              = 40
  type              = "gp3"
  encrypted         = true

  tags = {
    Name        = "${var.environment}-workload-storage"
    Environment = var.environment
    ManagedBy   = "OpenTofu"
  }
}

resource "aws_instance" "app_node" {
  ami               = "ami-05b5a865c3579bbc4" # Amazon Linux 2023 Minimal AMI
  instance_type     = var.instance_type
  availability_zone = "eu-west-3a"
  monitoring        = true
  ebs_optimized     = true

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required" # Enforce IMDSv2
    http_put_response_hop_limit = 1
  }

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    encrypted             = true
    delete_on_termination = true
  }

  user_data = <<-EOF
              #!/bin/bash
              set -euo pipefail
              export NODE_ENV="${var.environment}"
              export STORAGE_DEVICE="/dev/xvdh"
              export DATA_DIR="/var/app/data"

              mkdir -p "$DATA_DIR"
              echo "NODE_ENV=$NODE_ENV" > /etc/app.env
              echo "DATA_DIR=$DATA_DIR" >> /etc/app.env
              EOF

  tags = {
    Name        = "${var.environment}-app-compute"
    Environment = var.environment
    ManagedBy   = "OpenTofu"
  }
}

resource "aws_volume_attachment" "storage_attachment" {
  device_name = "/dev/xvdh"
  volume_id   = aws_ebs_volume.persistent_storage.id
  instance_id = aws_instance.app_node.id
}
