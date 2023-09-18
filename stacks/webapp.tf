resource "aws_s3_bucket" "platform_webapp" {
  bucket = "dashboard.apps.nagarajan.cloud" 

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "platform_webapp_access" {
  bucket = aws_s3_bucket.platform_webapp.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "angular_website_policy" {
  bucket = aws_s3_bucket.platform_webapp.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicRead"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.platform_webapp.arn}/*"
      }
    ]
  })
}

locals {
  content_types = {
    "html" = "text/html"
    "css"  = "text/css"
    "js"   = "application/javascript"
    "json" = "application/json"
    "png"  = "image/png"
    "jpg"  = "image/jpeg"
    "svg"  = "image/svg+xml"
    "ico"  = "image/x-icon"
  }
}

resource "aws_s3_bucket_object" "angular_files" {
  for_each = fileset("${path.module}/web-app/", "*")

  bucket  = aws_s3_bucket.platform_webapp.bucket
  key     = each.value
  source  = "web-app/${each.value}"
  etag    = filemd5("web-app/${each.value}")

  content_type = lookup(
    local.content_types,
    regex("\\.([^.]*)$", each.value)[0],
    "binary/octet-stream" // default
  )
}

output "website_url" {
  value = aws_s3_bucket.platform_webapp.website_endpoint
}
