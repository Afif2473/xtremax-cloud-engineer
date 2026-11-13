output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.this.dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.this.arn
}

output "alb_zone_id" {
  description = "Canonical hosted zone ID of the Application Load Balancer"
  value       = aws_lb.this.zone_id
}

output "target_group_arn" {
  description = "ARN of the WordPress ALB Target Group"
  value       = aws_lb_target_group.this.arn
}

output "asg_name" {
  description = "Name of the WordPress Auto Scaling Group"
  value       = aws_autoscaling_group.this.name
}
