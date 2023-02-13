# Configure the AWS Provider
provider "aws" {
  region = var.region
  #shared_credentials_files = "C:\\Users\\Admin\\.aws\\credentials"
  access_key = var.access_key
  secret_key = var.secret_key
  default_tags {
    tags = {
      Enviroment  = terraform.workspace
      Provisioned = "Terraform"
    }
  }
}

resource "aws_vpc" "Lab-1-VPC" {
  cidr_block       = var.aws_vpc_cidr
  instance_tenancy = "default"

  tags = {
    name           = "Lab-1-VPC"
    generated_from = "Terraform"
  }
}

resource "aws_subnet" "Lab-1-Subnet" {
  vpc_id                  = aws_vpc.Lab-1-VPC.id
  cidr_block              = var.aws_subnet_attributes.cidr_block
  map_public_ip_on_launch = "true"
  availability_zone       = var.aws_subnet_attributes.availability_zone

  tags = {
    name           = "Lab-1-Subnet"
    generated_from = "Terraform"
  }
}

resource "aws_internet_gateway" "Lab-1-IGW" {
  vpc_id = aws_vpc.Lab-1-VPC.id

  tags = {
    name           = "Lab-1-IGW"
    generated_from = "Terraform"
  }
}

resource "aws_default_route_table" "Lab-1-RT" {
  default_route_table_id =  aws_vpc.Lab-1-VPC.default_route_table_id

  route {
    cidr_block = var.Internet_IP_for_Routes
    gateway_id = aws_internet_gateway.Lab-1-IGW.id
  }

  tags = {
    name           = "Lab-1-RT"
    generated_from = "Terraform"
  }
}

resource "aws_default_security_group" "Lab-1-SG" {
  vpc_id      = aws_vpc.Lab-1-VPC.id

  tags = {
    name           = "Lab-1-SG"
    generated_from = "Terraform"
  }
}

resource "aws_security_group_rule" "Allow_Internet_Incoming" {
  type              = "ingress"
  protocol          = "tcp"
  from_port         = var.Allow_Internet.from_port
  to_port           = var.Allow_Internet.to_port
  cidr_blocks       = var.Internet_IP_for_SG
  security_group_id = aws_default_security_group.Lab-1-SG.id
}

resource "aws_security_group_rule" "Allow_Internet_Outgoing" {
  type              = "egress"
  protocol          = "tcp"
  from_port         = var.Allow_Internet.from_port
  to_port           = var.Allow_Internet.to_port
  cidr_blocks       = var.Internet_IP_for_SG
  security_group_id = aws_default_security_group.Lab-1-SG.id
}

resource "aws_eip" "Lab-1-EIP" {
  instance = aws_instance.AWS-Linux.id
  vpc      = true
  tags = {
    name           = "Lab-1-EIP"
    generated_from = "Terraform"
  }
}

resource "aws_instance" "AWS-Linux" {
  ami                    = var.aws_instance.ami
  instance_type          = var.aws_instance.instance_type
  tenancy                = "default"
  availability_zone      = var.aws_instance.availability_zone

  tags = {
    name           = "Lab-1-AWS-Linux"
    generated_from = "Terraform"
  }
}

resource "aws_eip_association" "Lab-1-EIP-Association" {
  instance_id   = aws_instance.AWS-Linux.id
  allocation_id = aws_eip.Lab-1-EIP.id
}
