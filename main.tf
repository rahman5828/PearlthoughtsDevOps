provider "aws" {
  region     = "us-east-1"

}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] 

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

resource "aws_instance" "terraform_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro" # Updated for Free Tier eligibility

  tags = {
    Name = "Autograph-Terraform-Server"
  }
}