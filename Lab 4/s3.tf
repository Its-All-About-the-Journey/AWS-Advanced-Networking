resource "aws_s3_bucket" "My_bucket" {
  bucket = "my-test-bucket-for-vpc-endpoints"
  tags = {
    Name = "My bucket"
  }
}

resource "aws_s3_bucket_acl" "my_bucket_acl" {
  bucket = aws_s3_bucket.My_bucket.id
  acl    = "public-read"
}

resource "aws_s3_object" "object" {
  bucket = "my-test-bucket-for-vpc-endpoints"
  key    = "curl.txt"
  source = "curl.txt"
  acl    = "public-read"

  etag = filemd5("curl.txt")
}


