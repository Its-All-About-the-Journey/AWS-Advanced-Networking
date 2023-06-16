
data "aws_eip" "CGW_EIP" {
  provider = aws.us-west-1
  public_ip       = aws_eip.CGW_EIP.public_ip
}
