resource "aws_vpc" "VPC" {
  cidr_block = "10.1.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
}

resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.VPC.id

  tags = {
    Name = "IGW"
  }
}

# Define the availability zones
variable "availability_zones" {
  default = ["us-west-2a", "us-west-2b"]  # Replace with your desired availability zones
}

# Create two public and two private subnets in different AZs
resource "aws_subnet" "public_subnets" {
  count = 2

  vpc_id                  = aws_vpc.VPC.id
  cidr_block              = "10.1.${1 + count.index}.0/24"
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true
  tags = {
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_route_table" "Public_RT" {
  vpc_id = aws_vpc.VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }

  tags = {
    Name = "Public_RT"
  }
}

resource "aws_route_table_association" "Public_RTA" {
  subnet_id      = aws_subnet.public_subnets[0].id
  route_table_id = aws_route_table.Public_RT.id
}

resource "aws_route_table_association" "Public_RTA2" {
  subnet_id      = aws_subnet.public_subnets[1].id
  route_table_id = aws_route_table.Public_RT.id
}

