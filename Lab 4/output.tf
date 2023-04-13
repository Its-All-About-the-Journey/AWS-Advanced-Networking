output "VPC_A_Public_Instance" {
  value = aws_instance.VPC_A_Public_Instance.public_ip
}

output "VPC_A_Private_Instance" {
  value = aws_instance.VPC_A_Private_Instance.private_ip
}

# Current S3 Object URL format
output "object_s3_url" {
  value = "https://${aws_s3_bucket.My_bucket.bucket}.s3.${var.aws_region}.amazonaws.com/${aws_s3_object.object.key}"
}
