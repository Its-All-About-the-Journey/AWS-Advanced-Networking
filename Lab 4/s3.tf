resource "aws_s3_bucket" "My_bucket" {
  bucket = "my-test-bucket-for-vpc-endpoints"
  tags = {
    Name = "My bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "public_bucket" {
  bucket = aws_s3_bucket.My_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_object" "object" {
  bucket = "my-test-bucket-for-vpc-endpoints"
  key    = "curl.txt"
  source = "curl.txt"

  etag = filemd5("curl.txt")
}


