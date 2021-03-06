terraform {
  backend "s3" {
    bucket = "my-dev-env1905"
    key    = "terraform/cicd.tfstate"
    region = "us-east-1"
   }
}

data "aws_caller_identity" "current" {}


data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name      = "name"
    values    = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name      = "owner-alias"
    values    = ["amazon"]
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  tags = {
    Name = "Test"
  }
}
