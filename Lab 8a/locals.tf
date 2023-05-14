locals {
  content_type_map = {
    "js"    = "application/javascript"
    "html"  = "text/html"
    "css"   = "text/css"
    "txt"   = "text/plain"
    "jpg"   = "image/jpeg"
    "png"   = "image/png"
    "gif"   = "image/gif"
    "php"   = "application/x-httpd-php"
    "woff"  = "font/woff"
    "woff2" = "font/woff2"
  }
}

locals {
  origin_id_map = {
    "s3_origin_id_1" = "S3_Origin_Primary"
    "s3_origin_id_2" = "S3_Origin_Secondary"
  }
}
