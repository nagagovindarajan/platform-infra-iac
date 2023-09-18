resource "aws_s3_bucket" "german-phonenos" {
  bucket = "german-phonenos"

  # Bucket access control configuration
  acl = "private"

  # Enable versioning for the bucket
  versioning {
    enabled = false
  }

  # Enable server-side encryption for the bucket
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  # Bucket policy to allow read and write access for Lambda
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com"
        ]
      },
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::german-phonenos",
        "arn:aws:s3:::german-phonenos/*"
      ],
      "Condition": {
        "IpAddress": {
          "aws:SourceIp": "182.55.86.137"
        }
      }
    }
  ]
}
EOF

}
