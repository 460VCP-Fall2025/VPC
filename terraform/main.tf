terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.3.0"
}

provider "aws" {
  region = "us-east-1"    # change if you prefer another region
}

# ---- Security group allowing SSH and HTTP ----
resource "aws_security_group" "web_sg" {
  name        = "ec2_test_sg"
  description = "Allow SSH and HTTP"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
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

# ---- Use the default VPC & subnet for simplicity ----
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}


# ---- EC2 Instance ----
resource "aws_instance" "test_instance" {
  ami                    = "ami-0c02fb55956c7d316"   # Amazon Linux 2 (us-east-1)
  instance_type          = "t3.micro"
  subnet_id = tolist(data.aws_subnets.default.ids)[0]
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               = "terraform-test-key"        # replace with your existing key pair name

  tags = {
    Name = "TerraformEC2-Test"
  }
}

# ---- Elastic IP ----
resource "aws_eip" "elastic_ip" {
  instance = aws_instance.test_instance.id
  domain   = "vpc"

  tags = {
    Name = "EC2-Test-EIP"
  }
}
