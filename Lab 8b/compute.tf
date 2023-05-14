resource "aws_instance" "Public_Instances_Fleet_1" {
  count         = 2
  ami           = "ami-04e914639d0cca79a"
  instance_type = "t2.micro"
  tenancy       = "default"
  key_name      = ""

  # 1/2=0.5 odd, 2/2=1 even, 3/2=1.5 odd, 4/2=2 even
  # if count.index is divided by 2 and the remainder is even, 
  # assign instance to aws_subnet.public_subnet_for_My_VPC_AZ_2A.id, 
  # else aws_subnet.public_subnet_for_My_VPC_AZ_2B.id
  subnet_id                   = count.index % 2 == 0 ? aws_subnet.public_subnet_for_My_VPC_AZ_2A.id : aws_subnet.public_subnet_for_My_VPC_AZ_2B.id
  security_groups             = ["${aws_security_group.My_VPC_SG.id}"]
  associate_public_ip_address = true
  
  # A web server is deployed
  user_data                   = <<-EOF
    #!/bin/bash
    sudo su
    sudo yum update -y
    sudo yum install nginx -y
    sudo systemctl start nginx
    sudo systemctl enable nginx
    sudo chmod 777 usr/share/nginx/html/
    cd usr/share/nginx/html/
    echo "<!DOCTYPE html><html><head><title>This is origin 1</title></head><body><h1>This is origin 1</h1><p>This is origin 1 web page.</p></body></html>" > origin_1.html
  EOF

  tags = {
    Name = "Instance ${count.index + 1}"
  }
}

# It should be applied after deploying all the configuratoion. This resource makes the Instances for Origin to appear unhealthy
# in the health check.
/*
resource "aws_ec2_instance_state" "stopped" {
  count = 2
  instance_id = data.aws_instance.Public_Instances_Fleet_1[count.index].id
  state       = "stopped"
}
*/

resource "aws_instance" "Public_Instances_Fleet_2" {
  count         = 2
  ami           = "ami-04e914639d0cca79a"
  instance_type = "t2.micro"
  tenancy       = "default"
  key_name      = ""

  # 1/2=0.5 odd, 2/2=1 even, 3/2=1.5 odd, 4/2=2 even
  # if count.index is divided by 2 and the remainder is even, 
  # assign instance to aws_subnet.public_subnet_for_My_VPC_AZ_2A.id, 
  # else aws_subnet.public_subnet_for_My_VPC_AZ_2B.id
  subnet_id                   = count.index % 2 == 0 ? aws_subnet.public_subnet_for_My_VPC_AZ_2A.id : aws_subnet.public_subnet_for_My_VPC_AZ_2B.id
  security_groups             = ["${aws_security_group.My_VPC_SG.id}"]
  associate_public_ip_address = true
  user_data                   = <<-EOF
    #!/bin/bash
    sudo su
    sudo yum update -y
    sudo yum install nginx -y
    sudo systemctl start nginx
    sudo systemctl enable nginx
    sudo chmod 777 usr/share/nginx/html/
    cd usr/share/nginx/html/
    echo "<!DOCTYPE html><html><head><title>This is origin 2</title></head><body><h1>This is origin 2</h1><p>This is origin 2 web page.</p></body></html>" > origin_2.html
  EOF

  tags = {
    Name = "Instance ${count.index + 1}"
  }
}

# ----------------------------------------------------------------------------------------------
resource "aws_s3_bucket" "Logs_Bucket" {
  bucket = "logs-bucket-logs-bucket"
  tags = {
    Name = "Logs_Bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "Logs_Bucket" {
  bucket = data.aws_s3_bucket.Logs_Bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Makes it possible to use ACL. As, it grants ownership to others.
resource "aws_s3_bucket_ownership_controls" "Logs_Bucket" {
  bucket = data.aws_s3_bucket.Logs_Bucket.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_acl" "Logs_Bucket" {
  depends_on = [
    aws_s3_bucket_public_access_block.Logs_Bucket,
    aws_s3_bucket_ownership_controls.Logs_Bucket,
  ]

  bucket = data.aws_s3_bucket.Logs_Bucket.id
  acl    = "public-read"
}
# ----------------------------------------------------------------------------------------------
