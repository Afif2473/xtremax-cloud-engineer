output "cloudfront_domain_name" {
  description = "Public HTTPS domain name for the school WordPress website"
  value       = module.cloudfront.cloudfront_domain_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront Distribution ID"
  value       = module.cloudfront.cloudfront_distribution_id
}

output "alb_dns_name" {
  description = "Application Load Balancer DNS name"
  value       = module.alb_asg.alb_dns_name
}

output "asg_name" {
  description = "WordPress Auto Scaling Group name"
  value       = module.alb_asg.asg_name
}

output "rds_endpoint" {
  description = "Private RDS MySQL endpoint"
  value       = module.rds.db_instance_endpoint
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}
