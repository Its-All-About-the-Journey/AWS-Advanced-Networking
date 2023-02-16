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

resource "aws_vpc" "Lab_2_VPC" {
  cidr_block       = var.aws_vpc_Lab_2_VPC
  instance_tenancy = "default"

  tags = {
    Name = "Lab_2_VPC"
  }
}

resource "aws_internet_gateway" "Lab_2_IGW" {
  vpc_id = aws_vpc.Lab_2_VPC.id

  tags = {
    Name = "Labs_2_IGW"
  }
}

resource "aws_subnet" "Public_A" {
  vpc_id                  = aws_vpc.Lab_2_VPC.id
  cidr_block              = var.aws_subnet_Public_A_attributes.cidr_block
  availability_zone       = var.aws_subnet_Public_A_attributes.availability_zone
  map_public_ip_on_launch = "true"

  tags = {
    Name = "Public_A"
  }
}

resource "aws_route_table" "Public_A_RT" {
  vpc_id = aws_vpc.Lab_2_VPC.id

  route {
    cidr_block = var.Internet_IP_for_Route_a_string
    gateway_id = aws_internet_gateway.Lab_2_IGW.id
  }

  tags = {
    Name = "Public_A_RT"
  }
}

resource "aws_route_table_association" "Public_A_RT_Association_A" {
  subnet_id      = aws_subnet.Public_A.id
  route_table_id = aws_route_table.Public_A_RT.id
}

resource "aws_instance" "Bastion" {
  ami               = var.aws_instance_Bastion_attributes.ami
  instance_type     = var.aws_instance_Bastion_attributes.instance_type
  availability_zone = var.aws_instance_Bastion_attributes.availability_zone
  key_name          = var.aws_instance_Bastion_attributes.key_name
  tenancy           = var.aws_instance_Bastion_attributes.tenancy
  subnet_id         = aws_subnet.Public_A.id
  security_groups   = ["${aws_security_group.SG_bastion.id}"]
}

resource "aws_security_group" "SG_bastion" {
  vpc_id      = aws_vpc.Lab_2_VPC.id
  description = " SG for bastion host. SSH access only"

  ingress {
    from_port   = var.SSH_attributes.from_port
    to_port     = var.SSH_attributes.to_port
    protocol    = "tcp"
    cidr_blocks = var.Internet_IP_for_SG_a_list
  }

  #egress {
  #  from_port   = 22
  #  to_port     = 22
  #  protocol    = "tcp"
  #  cidr_blocks = ["0.0.0.0/0"]
  #}
}

resource "aws_subnet" "Private_A" {
  vpc_id                  = aws_vpc.Lab_2_VPC.id
  cidr_block              = var.aws_subnet_Private_A_attributes.cidr_block
  availability_zone       = var.aws_subnet_Private_A_attributes.availability_zone
  map_public_ip_on_launch = "false"

  tags = {
    Name = "Public_A"
  }
}

resource "aws_route_table" "Private_Route_Table" {
  vpc_id = aws_vpc.Lab_2_VPC.id

  route {
    cidr_block = var.Internet_IP_for_Route_a_string
    #gateway_id = aws_internet_gateway.Lab_2_IGW.id
    gateway_id = aws_nat_gateway.NAT_GW.id
  }
}

resource "aws_route_table_association" "Private_Route_Table_Association" {
  subnet_id      = aws_subnet.Private_A.id
  route_table_id = aws_route_table.Private_Route_Table.id
}

resource "aws_network_acl" "Private_NACL" {
  vpc_id = aws_vpc.Lab_2_VPC.id

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = aws_subnet.Public_A.cidr_block
    from_port  = var.SSH_attributes.to_port
    to_port    = var.SSH_attributes.to_port
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = var.Internet_IP_for_Route_a_string
    from_port  = var.Euphemeral_ports_attributes.from_port
    to_port    = var.Euphemeral_ports_attributes.to_port
  }

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.Internet_IP_for_Route_a_string
    from_port  = var.HTTP_attributes.from_port
    to_port    = var.HTTP_attributes.to_port
  }

  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = var.Internet_IP_for_Route_a_string
    from_port  = var.HTTP_attributes.from_port
    to_port    = var.HTTP_attributes.to_port
  }

  egress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = aws_subnet.Public_A.cidr_block
    from_port  = var.Linux_ports_attributes.from_port
    to_port    = var.Linux_ports_attributes.to_port
  }
}

resource "aws_network_acl_association" "Private_NACL_Association" {
  network_acl_id = aws_network_acl.Private_NACL.id
  subnet_id      = aws_subnet.Private_A.id
}

resource "aws_instance" "Private_Instance" {
  ami               = var.aws_instance_Private_Instance_attributes.ami
  instance_type     = var.aws_instance_Private_Instance_attributes.instance_type
  availability_zone = var.aws_instance_Private_Instance_attributes.availability_zone
  key_name          = var.aws_instance_Private_Instance_attributes.key_name
  tenancy           = var.aws_instance_Private_Instance_attributes.tenancy
  subnet_id         = aws_subnet.Private_A.id
  security_groups   = ["${aws_security_group.SG_Private.id}"]
}

resource "aws_security_group" "SG_Private" {
  name        = "SG_Private"
  description = "Security group for private subnet instances."
  vpc_id      = aws_vpc.Lab_2_VPC.id

  ingress {
    description     = "Accept SSH inbound requests from Bastion host only."
    from_port       = var.SSH_attributes.from_port
    to_port         = var.SSH_attributes.to_port
    protocol        = "tcp"
    security_groups = [aws_security_group.SG_bastion.id]
  }

  ingress {
    description = "Accept HTTPS inbound requests from Public VPC CIDR."
    from_port   = var.HTTP_attributes.from_port
    to_port     = var.HTTP_attributes.to_port
    protocol    = "tcp"
    cidr_blocks = ["${aws_vpc.Lab_2_VPC.cidr_block}"]
  }
}

resource "aws_security_group_rule" "To_Bastion_SG_allow_SSH_from_SG_Private_Only" {
  type                     = "egress"
  from_port                = var.SSH_attributes.from_port
  to_port                  = var.SSH_attributes.to_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.SG_Private.id
  security_group_id        = aws_security_group.SG_bastion.id
}



resource "aws_eip" "EIP_for_NAT_GW" {
  vpc = true
}

resource "aws_nat_gateway" "NAT_GW" {
  subnet_id         = aws_subnet.Public_A.id
  connectivity_type = var.aws_nat_gateway_NAT_GW_attributes
  allocation_id     = aws_eip.EIP_for_NAT_GW.id

  tags = {
    "Name" = "NAT_GW"
  }
}
