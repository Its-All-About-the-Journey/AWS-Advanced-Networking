data "aws_cloudfront_distribution" "s3_distribution" {
  id       = aws_cloudfront_distribution.s3_distribution.id
  provider = aws.us-east-1
}

data "aws_s3_bucket" "Logs_Bucket" {
  bucket = aws_s3_bucket.Logs_Bucket.id
}

data "aws_s3_bucket" "Primary_Bucket" {
  bucket = aws_s3_bucket.Primary_Bucket.id
}

data "aws_s3_bucket" "Secondary_Bucket" {
  bucket = aws_s3_bucket.Secondary_Bucket.id
}

data "aws_cloudfront_origin_access_identity" "Primary_OAI" {
  id = aws_cloudfront_origin_access_identity.Primary_OAI.id
}

data "aws_cloudfront_origin_access_identity" "Secondary_OAI" {
  id = aws_cloudfront_origin_access_identity.Secondary_OAI.id
}
