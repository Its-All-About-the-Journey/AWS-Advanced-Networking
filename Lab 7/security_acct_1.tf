/*
Generate certs to be imported for Linux or Windows via the link below
https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/client-authentication.html
Move all files to a specific folder of your choice. Mine is a /certs/ folder.
*/

# Import server certificate
# Use your preferred certificate_body, private_key, or certificate_chain file name
resource "aws_acm_certificate" "server_certificate" {
  certificate_body  = file("certs/server.crt")
  private_key       = file("certs/server.key")
  certificate_chain = file("certs/ca.crt")

  provider = aws.Account_1

  tags = {
    Environment = "server_certificate"
  }
}

# Import client certificate
resource "aws_acm_certificate" "client_certificate" {
  certificate_body  = file("certs/client1.domain.tld.crt")
  private_key       = file("certs/client1.domain.tld.key")
  certificate_chain = file("certs/ca.crt")

  provider = aws.Account_1

  tags = {
    Environment = "client_certificate"
  }
}

resource "aws_ec2_client_vpn_endpoint" "client_vpn" {
  description            = "clientvpn"
  vpc_id                 = aws_vpc.VPC_A.id
  server_certificate_arn = aws_acm_certificate.server_certificate.arn
  client_cidr_block      = "172.16.0.0/22"
  
  # The split tunnel shows it is a policy based VPN. This because setting it to "true"
  # will set an access control list so only Traffic from your client go through the VPN.
  split_tunnel           = true
  security_group_ids     = ["${aws_security_group.VPC_A_SG.id}"]
  vpn_port               = 443

  provider = aws.Account_1

  # Information about the authentication method to be used to authenticate clients.
  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = aws_acm_certificate.client_certificate.arn
  }

  connection_log_options {
    enabled = false
  }
}

# For multiple subnets in the same VPC, each subnet must be in different AZs
resource "aws_ec2_client_vpn_network_association" "VPC_A_private_subnet_vpn_association" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_vpn.id
  subnet_id              = aws_subnet.private_subnet_for_VPC_A_AZ_2A.id

  provider = aws.Account_1
}

# The CIDR range allowed to access the Client VPN
resource "aws_ec2_client_vpn_authorization_rule" "client_vpn_authorization_rule" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_vpn.id
  target_network_cidr    = "0.0.0.0/0"
  authorize_all_groups   = true

  provider = aws.Account_1
}

resource "aws_security_group" "VPC_A_SG" {
  name        = "VPC_A_SG"
  description = "Allow SSH, HTTPS, and ICMP inbound traffic"
  vpc_id      = aws_vpc.VPC_A.id

  provider = aws.Account_1

  ingress {
    description = "SSH into VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS into VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ICMP into VPC"
    from_port   = -1
    to_port     = -1
    protocol    = "ICMP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "VPC_A_SG"
  }
}

resource "aws_security_group" "VPC_B_SG" {
  name        = "VPC_B_SG"
  description = "Allow SSH, HTTPS, and ICMP inbound traffic"
  vpc_id      = aws_vpc.VPC_B.id

  provider = aws.Account_1

  ingress {
    description = "SSH into VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS into VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ICMP into VPC"
    from_port   = -1
    to_port     = -1
    protocol    = "ICMP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "VPC_B_SG"
  }
}

