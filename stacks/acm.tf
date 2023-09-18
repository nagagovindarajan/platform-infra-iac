resource "aws_acm_certificate" "app_certificate" {
  domain_name       = "*.apps.nagarajan.cloud"
  validation_method = "DNS"

  tags = {
    Name = "nagarajan-cloud-certificate"
  }
}

resource "aws_route53_record" "certificate_verification" {
  zone_id = aws_route53_zone.nagarajan-cloud.zone_id
  name    = tolist(aws_acm_certificate.app_certificate.domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.app_certificate.domain_validation_options)[0].resource_record_type
  records = [tolist(aws_acm_certificate.app_certificate.domain_validation_options)[0].resource_record_value]
  ttl     = 300

  # Ensure the record is associated with the certificate's validation domain
  allow_overwrite = true
}