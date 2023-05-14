resource "aws_s3_bucket" "Primary_Bucket" {
  bucket = "primary-bucket-primary-bucket"
  tags = {
    Name = "Primary_Bucket"
  }
}

resource "aws_s3_bucket" "Secondary_Bucket" {
  bucket = "secondary-bucket-secondary-bucket"
  tags = {
    Name = "Secondary_Bucket"
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

resource "aws_s3_object" "Primary_Object" {
  # Use a for loop to grab every file in the folder.
  # The fileset() function is used to read all the files in a folder.
  # The ** is usd to read and upload every file.
  # The /* is used to read every file in a sub-folder and then upload the sub-folder along with its files.
  for_each = fileset("${path.module}/${var.website}/", "**/*")

  bucket = aws_s3_bucket.Primary_Bucket.bucket
  key    = each.value
  source = "${path.module}/${var.website}/${each.value}"
  etag   = filemd5("${path.module}/${var.website}/${each.value}")
  /*
    1) The split() function is called with "." as the delimiter and an each.value like
    "owl.theme.green.min.css" as the input string:
    This returns an array of parts: ["owl", "theme", "green", "min", "css"]
    2) The length() function is called with the result of split() as the input:
    This returns the length of the array, which is 5.
    3) We subtract 1 from the length of the array to get the index of the last 
    element, which is the file extension:
    This returns 4, which is the index of "css" in the array.
    4) We use this index to extract the file extension from the array:
    This returns "css", which is the file extension we're interested in.
    5) Finally, we use the file extension "css" to look up the corresponding 
    content type in the local.content_type_map variable using the lookup() function:
    This will return the content type associated with "css", which could be something 
    like "text/css" depending on how local.content_type_map is defined.
  */
  content_type = lookup(local.content_type_map, split(".", "${each.value}")[length(split(".", "${each.value}")) - 1], "application/octet-stream")
  #depends_on   = [aws_s3_bucket_policy.bucket_policy]
}

resource "aws_s3_object" "Secondary_Object" {

  for_each     = fileset("${path.module}/${var.website_2}/", "**/*")
  bucket       = data.aws_s3_bucket.Secondary_Bucket.id
  key          = each.value
  source       = "${path.module}/${var.website_2}/${each.value}"
  etag         = filemd5("${path.module}/${var.website_2}/${each.value}")
  content_type = lookup(local.content_type_map, split(".", "${each.value}")[length(split(".", "${each.value}")) - 1], "application/octet-stream")
}


/*
----------------------------------------------------------------------------------------
    Policies
----------------------------------------------------------------------------------------
*/

resource "aws_cloudfront_origin_access_identity" "Primary_OAI" {
  comment = "Primary_OAI"
}

resource "aws_cloudfront_origin_access_identity" "Secondary_OAI" {
  comment = "Secondary_OAI"
}

resource "aws_s3_bucket_policy" "Primary_Bucket_Policy" {
  bucket = data.aws_s3_bucket.Primary_Bucket.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression's result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "Allow_OAI_Read_Only"
    Statement = [
      {
        Sid    = "PublicRead"
        Effect = "Allow"
        Principal = {
          AWS = "${data.aws_cloudfront_origin_access_identity.Primary_OAI.iam_arn}"
        }
        Action = [
          "s3:GetObject"
        ]
        Resource = [
          "${data.aws_s3_bucket.Primary_Bucket.arn}/*"
        ]
      },
    ]
  })
}

resource "aws_s3_bucket_policy" "Secondary_Bucket_Policy" {
  bucket = data.aws_s3_bucket.Secondary_Bucket.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression's result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "Allow_OAI_Read_Only"
    Statement = [
      {
        Sid    = "PublicRead"
        Effect = "Allow"
        Principal = {
          AWS = "${data.aws_cloudfront_origin_access_identity.Secondary_OAI.iam_arn}"
        }
        Action = [
          "s3:GetObject"
        ]
        Resource = [
          "${data.aws_s3_bucket.Secondary_Bucket.arn}/*"
        ]
      },
    ]
  })
}

resource "aws_s3_bucket_website_configuration" "Primary_Website_Config" {
  bucket = data.aws_s3_bucket.Primary_Bucket.id

  index_document {
    suffix = "index.html"
  }

  depends_on = [aws_s3_object.Primary_Object]
}

resource "aws_s3_bucket_website_configuration" "Secondary_Website_Config" {
  bucket = data.aws_s3_bucket.Secondary_Bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  depends_on = [aws_s3_object.Secondary_Object]
}

/*
-------------------------------------------------------------------------------
                                    SSL
-------------------------------------------------------------------------------
*/
resource "aws_acm_certificate" "cert" {
  provider          = aws.us-east-1
  domain_name       = ""
  validation_method = "DNS"

  tags = {
    Environment = "Terraform"
  }
}

# Cert must first be created and then its CNAME must be added to R53 before validation occurs
resource "aws_acm_certificate_validation" "cert_validation" {
  provider                = aws.us-east-1
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.ACM : record.fqdn]

  depends_on = [aws_acm_certificate.cert, aws_route53_record.ACM]
}

/*
-------------------------------------------------------------------------------
                                    Cloudfront
-------------------------------------------------------------------------------
*/
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin_group {
    origin_id = "Origin Group"

    failover_criteria {
      status_codes = [400, 403, 404, 416, 500, 502, 503, 504]
    }

    member {
      origin_id = local.origin_id_map.s3_origin_id_1
    }

    member {
      origin_id = local.origin_id_map.s3_origin_id_2
    }
  }

  origin {
    domain_name = data.aws_s3_bucket.Primary_Bucket.bucket_regional_domain_name
    origin_id   = local.origin_id_map.s3_origin_id_1

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.Primary_OAI.cloudfront_access_identity_path
    }
  }

  origin {
    domain_name = data.aws_s3_bucket.Secondary_Bucket.bucket_regional_domain_name
    origin_id   = local.origin_id_map.s3_origin_id_2

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.Secondary_OAI.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods        = ["OPTIONS", "GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "Origin Group"
    viewer_protocol_policy = "https-only"

    min_ttl     = 0
    default_ttl = 3
    max_ttl     = 300

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "S3 Distribution"
  default_root_object = "index.html"

  provider = aws.us-east-1 # Needed because ACM is a regional resource, and it must be issued before
  # it is assigned here.
  viewer_certificate {
    acm_certificate_arn            = aws_acm_certificate.cert.arn
    cloudfront_default_certificate = true
    ssl_support_method             = "sni-only"
  }

  aliases = [aws_acm_certificate.cert.domain_name]

  logging_config {
    bucket = data.aws_s3_bucket.Logs_Bucket.bucket_domain_name
    prefix = "logs/"
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "NG"]
    }
  }

  tags = {
    Environment = "Terraform"
  }

  depends_on = [aws_acm_certificate_validation.cert_validation]
}

/*
-------------------------------------------------------------------------------
                                    ROUTE 53
-------------------------------------------------------------------------------
*/

resource "aws_route53_record" "ACM" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name # domain name
  records         = [each.value.record]
  type            = each.value.type # CNAME 
  ttl             = 60
  zone_id         = var.hosted_zone_id

  /*

Let's assume you have the following values for the 
aws_acm_certificate.cert.domain_validation_options attribute:

aws_acm_certificate.cert.domain_validation_options = [
  {
    domain_name              = "example.com"
    resource_record_name     = "_acme-challenge.example.com"
    resource_record_value    = "ABC123DEF456"
    resource_record_type     = "TXT"
  },
  {
    domain_name              = "subdomain.example.com"
    resource_record_name     = "_acme-challenge.subdomain.example.com"
    resource_record_value    = "XYZ789UVW321"
    resource_record_type     = "TXT"
  },
]

dvo.domain_name will take "example.com" as a key, while others will be its key and values.
"example.com" = {
  resource_record_name     = "_acme-challenge.example.com"
  resource_record_value    = "ABC123DEF456"
  resource_record_type     = "TXT"
}

They can be referenced again by using the each.value.key where the key can be a name, record or type.
*/
}

resource "aws_route53_record" "Cloudfront" {
  zone_id = var.hosted_zone_id
  name    = aws_acm_certificate.cert.domain_name
  type    = "A"

  alias {
    name                   = data.aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = data.aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = true
  }
}
