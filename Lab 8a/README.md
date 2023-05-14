```h
I struggled with not realizing that to expose objects of a bucket, I simply
just need to specify a bucket policy that gets all object. The bucket must first be public.

resource "aws_s3_bucket_public_access_block" "public_bucket_access" {
  bucket = aws_s3_bucket.My_bucket.bucket

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false

  depends_on = [aws_s3_bucket.My_bucket]
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
        Sid       = "PublicRead"
        Effect    = "Allow"
        Principal = "*"
        Action = [
          "s3:GetObject"
        ]
        Resource = [
          "${aws_s3_bucket.My_bucket.arn}/*",
        ]
      },
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.public_bucket_access]
}


I used a lot of depends_on in my code because some resources need to applied first before another.
For example, a bucket must be public first before a policy must be applied to it.

I also struggled with knowing how to upload files and sub-folders together. Using a for-loop, a fileset() and other functions helped a lot here. You can find these in the object resource.

If you are using your own website, make sure to get the file types in the folder. This is specified as a content type in your object meta-data. Since your objects are for a website, specifying a content_type attribute in your object resource is a must.

Specify the file type in the locals block. It should be based on the MIME Type.
MIME (Multipurpose Internet Mail Extensions) is an extension of the original Simple Mail Transport Protocol (SMTP) email protocol. It lets users exchange different kinds of data files, including audio, video, images and application programs, over email.
So a .css file type is represented as a text/css on the website.

Also, I learnt that if you are using an s3 bucket as a website, the index.html file must be in the root bucket. Also, a website configuration block is necessaary, as it points to the index.html and error.html in your root s3 bucket. But this resource is not necessary when using cloudfront funny enough.

resource "aws_s3_bucket_website_configuration" "Primary_Website_Config" {
  bucket = aws_s3_bucket.Primary_Bucket.bucket

  index_document {
    suffix = "index.html"
  }

  depends_on = [aws_s3_object.Primary_Object]
}

resource "aws_s3_bucket_website_configuration" "Secondary_Website_Config" {
  bucket = aws_s3_bucket.Secondary_Bucket.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  depends_on = [aws_s3_object.Secondary_Object]
}


If you want to reference a particular path in your website, this is where ordered cache behaviour in your cloufront resource comes into play.
  # Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "primary/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "Origin Group"
    viewer_protocol_policy = "https-only"
    min_ttl                = 0
    default_ttl            = 3
    max_ttl                = 300

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }
  }

  # Cache behavior with precedence 1
  ordered_cache_behavior {
    path_pattern     = "secondary/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "Origin Group"
    viewer_protocol_policy = "https-only"
    min_ttl                = 0
    default_ttl            = 3
    max_ttl                = 3

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }
  }

The time to live (ttl) values indicates how long the object stays in the edge cache server. You can also used the `curl -I url` command via the CLI to investigate this.
The -I signifies that the curl should Include headers.
Or you can use the log attribute of your cloudfront resource, and find your logs in your new s3 bucket. Specifically the "x-edge-result-type" so you can know when an object is at the cache or not.

I also learnt to use data sources more often than usual. It helps on an error like a cycle dependency where resources depend on each other hence causing an error.

I did not use data sources for the ACM certs because it assumes that the certs are issued already.