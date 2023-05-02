resource "aws_s3_bucket" "My_bucket" {
  bucket = "my-test-bucket-for-vpc-endpoints"
  tags = {
    Name = "My bucket"
  }
}

resource "aws_s3_object" "object" {
  bucket = aws_s3_bucket.My_bucket.bucket
  key    = "curl.txt"
  source = "curl.txt"

  etag = filemd5("curl.txt")
}

resource "aws_s3_bucket_public_access_block" "public_bucket_access" {
  bucket = aws_s3_bucket.My_bucket.bucket

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.My_bucket.bucket

  # Terraform's "jsonencode" function converts a
  # Terraform expression's result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "MYBUCKETPOLICY"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = [
                "s3:GetObject"
            ]
        Resource = [
          aws_s3_bucket.My_bucket.arn,
          "${aws_s3_bucket.My_bucket.arn}/*",
        ]
      },
    ]
  })
}
