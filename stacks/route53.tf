resource "aws_route53_zone" "nagarajan-cloud" {
  name = var.MAIN_HOST
}

output "ns-servers" {
  value = aws_route53_zone.nagarajan-cloud.name_servers
}

resource "aws_route53_record" "platform-record" {
  zone_id = aws_route53_zone.nagarajan-cloud.zone_id
  name    = var.ALB_DOMAIN
  type    = "A"
  alias {
    name                   = aws_alb.platform-alb.dns_name
    zone_id                = aws_alb.platform-alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "platform_webapp" {
  zone_id = aws_route53_zone.nagarajan-cloud.zone_id
  name    = var.WEB_APP_DOMAIN
  type    = "A"

  alias {
    name                   = aws_s3_bucket.platform_webapp.website_domain
    zone_id                = aws_s3_bucket.platform_webapp.hosted_zone_id
    evaluate_target_health = false
  }
}
