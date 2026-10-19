terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.40"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = "Smart-Library-Management"
      ManagedBy = "Terraform"
    }
  }
}
resource "aws_vpc" "library_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "smart-library-vpc"
  }
}
resource "aws_subnet" "library_public_subnet" {
  vpc_id                  = aws_vpc.library_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "smart-library-public-subnet"
  }
}
resource "aws_internet_gateway" "library_igw" {
  vpc_id = aws_vpc.library_vpc.id

  tags = {
    Name = "smart-library-igw"
  }
}
resource "aws_route_table" "library_public_rt" {
  vpc_id = aws_vpc.library_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.library_igw.id
  }

  tags = {
    Name = "smart-library-public-rt"
  }
}
resource "aws_route_table_association" "library_public_association" {
  subnet_id      = aws_subnet.library_public_subnet.id
  route_table_id = aws_route_table.library_public_rt.id
}
resource "aws_security_group" "library_sg" {
  name        = "smart-library-sg"
  description = "Security group for Smart Library"
  vpc_id      = aws_vpc.library_vpc.id

  ingress {
    description = "HTTP web access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH access - restrict to your IP before deployment"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["152.56.4.8/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "smart-library-sg"
  }
}
resource "aws_instance" "library_ec2" {
  ami                         = "ami-009df87a702c8675c"
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.library_public_subnet.id
  vpc_security_group_ids      = [aws_security_group.library_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "smart-library-ec2"
  }
}
