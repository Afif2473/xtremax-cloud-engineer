variable "project_name" {
  description = "Project name used for resource naming and tagging"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "alb_dns_name" {
  description = "DNS name of the Application Load Balancer used as CloudFront origin"
  type        = string
}

variable "cf_acm_certificate_arn" {
  description = "ACM Certificate ARN (in us-east-1) for CloudFront HTTPS. Leave empty to use default CloudFront cert"
  type        = string
}

variable "price_class" {
  description = "CloudFront distribution price class"
  type        = string
}
