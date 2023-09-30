#########################################################################
#                             WORKLOAD                                  #
#########################################################################
resource "aws_vpc" "Workload_VPC" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Workload_VPC"
  }
}

resource "aws_internet_gateway" "Workload_VPC_IGW" {
  vpc_id = aws_vpc.Workload_VPC.id

  tags = {
    "name" = "Workload_VPC_IGW"
  }
}

resource "aws_subnet" "Private" {
  vpc_id            = aws_vpc.Workload_VPC.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "Private"
  }
}

resource "aws_subnet" "Public" {
  vpc_id            = aws_vpc.Workload_VPC.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "Public"
  }
}

resource "aws_subnet" "GWLB" {
  vpc_id            = aws_vpc.Workload_VPC.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "GWLB"
  }
}

resource "aws_eip" "NGW" {
  domain = "vpc"

  tags = {
    Name = "NGW"
  }
}

resource "aws_nat_gateway" "NGW" {
  allocation_id = aws_eip.NGW.id
  subnet_id = aws_subnet.Public.id
  
  tags = {
    Name = "NGW"
  }
}

resource "aws_route_table" "Public_RT" {
  vpc_id = aws_vpc.Workload_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Workload_VPC_IGW.id
  }

  tags = {
    Name = "Public_RT"
  }
}

resource "aws_route_table" "Private_RT" {
  vpc_id = aws_vpc.Workload_VPC.id

  route {
    cidr_block = "8.8.8.8/32"
    nat_gateway_id = aws_nat_gateway.NGW.id
  }

  tags = {
    Name = "Private_RT"
  }
}

resource "aws_route_table" "GWLB_RT" {
  vpc_id = aws_vpc.Workload_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    vpc_endpoint_id = aws_vpc_endpoint.GWLBE1.id
  }

  tags = {
    Name = "GWLB_RT"
  }
}

resource "aws_route_table_association" "Public_RTA" {
  subnet_id      = aws_subnet.Public.id
  route_table_id = aws_route_table.Public_RT.id
}

resource "aws_route_table_association" "Private_RTA" {
  subnet_id      = aws_subnet.Private.id
  route_table_id = aws_route_table.Private_RT.id
}

resource "aws_route_table_association" "GWLB_RTA" {
  subnet_id      = aws_subnet.GWLB.id
  route_table_id = aws_route_table.GWLB_RT.id
}

resource "aws_vpc_endpoint" "GWLBE1" {
  auto_accept = true
  service_name      = aws_vpc_endpoint_service.GWLBE-Service.service_name
  subnet_ids        = [aws_subnet.GWLB.id]
  vpc_endpoint_type = aws_vpc_endpoint_service.GWLBE-Service.service_type
  vpc_id            = aws_vpc.Workload_VPC.id
}

#########################################################################
#                             SECURITY                                  #
#########################################################################
resource "aws_vpc" "Security_VPC" {
  cidr_block           = "10.1.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Security_VPC"
  }
}

resource "aws_internet_gateway" "Security_VPC_IGW" {
  vpc_id = aws_vpc.Security_VPC.id

  tags = {
    "name" = "Security_VPC_IGW"
  }
}

resource "aws_subnet" "Data_Traffic_Subnet_1" {
  vpc_id            = aws_vpc.Security_VPC.id
  cidr_block        = "10.1.1.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "Data_Traffic_Subnet_1"
  }
}

resource "aws_subnet" "Data_Traffic_Subnet_2" {
  vpc_id            = aws_vpc.Security_VPC.id
  cidr_block        = "10.1.2.0/24"
  availability_zone = "us-west-2b"

  tags = {
    Name = "Data_Traffic_Subnet_2"
  }
}

resource "aws_subnet" "Management_Traffic_Subnet_1" {
  vpc_id            = aws_vpc.Security_VPC.id
  cidr_block        = "10.1.3.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "Management_Traffic_Subnet_1"
  }
}

resource "aws_subnet" "Management_Traffic_Subnet_2" {
  vpc_id            = aws_vpc.Security_VPC.id
  cidr_block        = "10.1.4.0/24"
  availability_zone = "us-west-2b"

  tags = {
    Name = "Management_Traffic_Subnet_2"
  }
}

resource "aws_eip" "MGT1" {
  domain = "vpc"

  tags = {
    Name = "MGT1"
  }
}

resource "aws_eip_association" "MGT1" {
  allocation_id = aws_eip.MGT1.id
  network_interface_id = aws_network_interface.Management_Interface1.id
}

resource "aws_eip" "MGT2" {
  domain = "vpc"

  tags = {
    Name = "MGT2"
  }
}

resource "aws_eip_association" "MGT2" {
  allocation_id = aws_eip.MGT2.id
  network_interface_id = aws_network_interface.Management_Interface2.id
}

resource "aws_vpc_endpoint_service" "GWLBE-Service" {
  acceptance_required        = false
  allowed_principals         = [data.aws_caller_identity.current.arn]
  # Attach GWLB in the Security VPC
  gateway_load_balancer_arns = [aws_lb.My_GWLB.arn]
}

resource "aws_vpc_endpoint" "GWLBE2" {
  auto_accept = true
  service_name      = aws_vpc_endpoint_service.GWLBE-Service.service_name
  subnet_ids        = [aws_subnet.Data_Traffic_Subnet_1.id]
  vpc_endpoint_type = aws_vpc_endpoint_service.GWLBE-Service.service_type
  vpc_id            = aws_vpc.Security_VPC.id
}

resource "aws_vpc_endpoint" "GWLBE3" {
  auto_accept = true
  service_name      = aws_vpc_endpoint_service.GWLBE-Service.service_name
  subnet_ids        = [aws_subnet.Data_Traffic_Subnet_2.id]
  vpc_endpoint_type = aws_vpc_endpoint_service.GWLBE-Service.service_type
  vpc_id            = aws_vpc.Security_VPC.id
}

resource "aws_route_table" "Management_Traffic_RT" {
  vpc_id = aws_vpc.Security_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Security_VPC_IGW.id
  }

  tags = {
    Name = "Management_Traffic_RT"
  }
}

resource "aws_route_table_association" "Management_Traffic1_RTA" {
  subnet_id      = aws_subnet.Management_Traffic_Subnet_1.id
  route_table_id = aws_route_table.Management_Traffic_RT.id
}

resource "aws_route_table_association" "Management_Traffic2_RTA" {
  subnet_id      = aws_subnet.Management_Traffic_Subnet_2.id
  route_table_id = aws_route_table.Management_Traffic_RT.id
}

resource "aws_route_table" "Data_Traffic_RT1" {
  vpc_id = aws_vpc.Security_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    vpc_endpoint_id = aws_vpc_endpoint.GWLBE2.id
  }

  tags = {
    Name = "Data_Traffic_RT1"
  }
}

resource "aws_route_table" "Data_Traffic_RT2" {
  vpc_id = aws_vpc.Security_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    vpc_endpoint_id = aws_vpc_endpoint.GWLBE3.id
  }

  tags = {
    Name = "Data_Traffic_RT2"
  }
}

resource "aws_route_table_association" "Data_Traffic1_RTA" {
  subnet_id      = aws_subnet.Data_Traffic_Subnet_1.id
  route_table_id = aws_route_table.Data_Traffic_RT1.id
}

resource "aws_route_table_association" "Data_Traffic2_RTA" {
  subnet_id      = aws_subnet.Data_Traffic_Subnet_2.id
  route_table_id = aws_route_table.Data_Traffic_RT2.id
}

