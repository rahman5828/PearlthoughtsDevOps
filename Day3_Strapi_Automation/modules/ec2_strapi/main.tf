# 1. Generate the RSA Private Key
resource "tls_private_key" "strapi_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# 2. Save the .pem file to the Root folder (Managed by Terraform)
resource "local_file" "private_key" {
  content         = tls_private_key.strapi_key.private_key_pem
  filename        = "${path.root}/strapi-key.pem"
  file_permission = "0400"
}

# 3. Create the AWS Key Pair using the public key from the resource above
resource "aws_key_pair" "deployer" {
  key_name   = "strapi-deployer-key-v3" # Unique name to avoid duplicate errors
  public_key = tls_private_key.strapi_key.public_key_openssh
}

# 4. Create Security Group for SSH (22) and Strapi (1337)
resource "aws_security_group" "strapi_sg" {
  name        = "strapi-security-group-v3" # Unique name to avoid duplicate errors
  description = "Allow SSH and Strapi traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 1337
    to_port     = 1337
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 5. Launch the EC2 Instance
resource "aws_instance" "strapi_server" {
  ami           = "ami-04a81a99f5ec58529" # Ubuntu 24.04 LTS in us-east-1
  instance_type = "t3.small"               # 2GB RAM required for Strapi
  key_name      = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.strapi_sg.id]

  # Automation: Install Node.js 20 on startup
  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
              sudo apt install -y nodejs build-essential
              EOF

  tags = {
    Name = "Strapi-Server-Day3"
  }
}