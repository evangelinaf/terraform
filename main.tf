terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  profile = "efiorucci"
  region  = "us-west-2"
}

resource "aws_instance" "ec2-instance" {
  ami           = "ami-22eb9e5a"
  instance_type = "t1.micro"

  tags = {
    Name = "Terraform-test-by-Eva"
    }
  }
