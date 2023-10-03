resource "aws_network_interface" "Instance_A" {
  subnet_id       = aws_subnet.Public_A.id
  private_ips     = ["10.0.0.10"]
  security_groups = [aws_security_group.SG.id]
  ipv6_address_count = 1

  tags = {
    "Name" = "Instance_A"
  }
}

resource "aws_ec2_instance_state" "running1" {
  instance_id = aws_instance.Instance_A.id
  state       = "running"
}

resource "aws_eip" "one" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.Instance_A.id

  depends_on = [ aws_ec2_instance_state.running1 ]
}

resource "aws_instance" "Instance_A" {
  ami               = "ami-03f65b8614a860c29"
  instance_type     = "t3.micro"
  availability_zone = "us-west-2a"
  tenancy           = "default"
  key_name          = ""

  network_interface {
    network_interface_id = aws_network_interface.Instance_A.id
    device_index         = 0
  }

  tags = {
    "Name" = "Instance A"
  }
}

resource "aws_network_interface" "Instance_B" {
  subnet_id       = aws_subnet.Public_B.id
  private_ips     = ["10.0.1.20"]
  ipv6_address_count = 1
  security_groups = [aws_security_group.SG.id]
}

resource "aws_ec2_instance_state" "running2" {
  instance_id = aws_instance.Instance_B.id
  state       = "running"
}

resource "aws_eip" "two" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.Instance_B.id

  depends_on = [ aws_ec2_instance_state.running2 ]
}

resource "aws_instance" "Instance_B" {
  ami               = "ami-03f65b8614a860c29"
  instance_type     = "t3.micro"
  availability_zone = "us-west-2b"
  tenancy           = "default"
  key_name          = ""

  network_interface {
    network_interface_id = aws_network_interface.Instance_B.id
    device_index         = 0
  }

  tags = {
    "Name" = "Instance B"
  }
}

resource "aws_network_interface" "Instance_C" {
  subnet_id       = aws_subnet.Private_A.id
  private_ips     = ["10.0.2.10"]
  ipv6_address_count = 1
  security_groups = [aws_security_group.SG.id]
}

resource "aws_instance" "Instance_C" {
  ami               = "ami-03f65b8614a860c29"
  instance_type     = "t3.micro"
  availability_zone = "us-west-2a"
  tenancy           = "default"

  network_interface {
    network_interface_id = aws_network_interface.Instance_C.id
    device_index         = 0
  }

  tags = {
    "Name" = "Instance C"
  }
}

resource "aws_network_interface" "Instance_D" {
  subnet_id       = aws_subnet.Private_B.id
  private_ips     = ["10.0.3.20"]
  ipv6_address_count = 1
  security_groups = [aws_security_group.SG.id]
}

resource "aws_instance" "Instance_D" {
  ami               = "ami-03f65b8614a860c29"
  instance_type     = "t3.micro"
  availability_zone = "us-west-2b"
  tenancy           = "default"

  network_interface {
    network_interface_id = aws_network_interface.Instance_D.id
    device_index         = 0
  }

  tags = {
    "Name" = "Instance D"
  }
}
