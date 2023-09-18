resource "aws_route53_zone" "nagarajan-cloud" {
  name = "apps.nagarajan.cloud"
}

output "ns-servers" {
  value = aws_route53_zone.nagarajan-cloud.name_servers
}

resource "aws_route53_record" "naga_api" {
  zone_id = aws_route53_zone.nagarajan-cloud.zone_id
  name    = aws_api_gateway_domain_name.naga_api.domain_name
  type    = "A"

  alias {
    name                   = aws_api_gateway_domain_name.naga_api.cloudfront_domain_name
    zone_id                = aws_api_gateway_domain_name.naga_api.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "platform-record" {
  zone_id = aws_route53_zone.nagarajan-cloud.zone_id
  name    = "platform.apps.nagarajan.cloud"
  type    = "A"
  alias {
    name                   = aws_alb.platform-alb.dns_name
    zone_id                = aws_alb.platform-alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "platform_webapp" {
  zone_id = aws_route53_zone.nagarajan-cloud.zone_id
  name    = "dashboard.apps.nagarajan.cloud"
  type    = "A"

  alias {
    name                   = aws_s3_bucket.platform_webapp.website_domain
    zone_id                = aws_s3_bucket.platform_webapp.hosted_zone_id
    evaluate_target_health = false
  }
}
