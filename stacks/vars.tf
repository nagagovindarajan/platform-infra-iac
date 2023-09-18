variable "AWS_REGION" {
  default = "ap-southeast-1"
}

variable "MAIN_HOST" {
  default = "apps.nagarajan.cloud"
}

variable "ACM_DOMAIN" {
  default = "*.apps.nagarajan.cloud"
}

variable "ALB_DOMAIN" {
  default = "platform.apps.nagarajan.cloud"
}

variable "WEB_APP_DOMAIN" {
  default = "dashboard.apps.nagarajan.cloud"
}