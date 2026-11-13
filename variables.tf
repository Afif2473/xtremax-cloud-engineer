# General

variable "aws_region" {
  description = "AWS region for infrastructure deployment"
  type        = string
}

variable "project_name" {
  description = "Project name used for resource naming and tagging"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

# VPC & Networking

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "azs" {
  description = "List of Availability Zones"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_app_subnet_cidrs" {
  description = "CIDR blocks for private application subnets"
  type        = list(string)
}

variable "private_db_subnet_cidrs" {
  description = "CIDR blocks for isolated private database subnets"
  type        = list(string)
}

# IAM

variable "ssm_db_param_arn" {
  description = "ARN of the SSM Parameter storing database configuration"
  type        = string
}

variable "log_group_arn" {
  description = "ARN pattern of the CloudWatch Log Group for EC2 logs"
  type        = string
}

# RDS MySQL

variable "db_name" {
  description = "Initial MySQL database name for WordPress"
  type        = string
}

variable "db_username" {
  description = "Master username for RDS MySQL"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Master password for RDS MySQL"
  type        = string
  sensitive   = true
}

variable "engine_version" {
  description = "MySQL engine version"
  type        = string
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
}

variable "allocated_storage" {
  description = "RDS allocated storage in GiB"
  type        = number
}

variable "multi_az" {
  description = "Enable Multi-AZ for RDS"
  type        = bool
}

variable "backup_retention_period" {
  description = "RDS automated backup retention in days"
  type        = number
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot when destroying RDS"
  type        = bool
}

variable "deletion_protection" {
  description = "Enable RDS deletion protection"
  type        = bool
}

# ALB & EC2 Auto Scaling

variable "wordpress_ami_id" {
  description = "WordPress AMI ID"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for WordPress"
  type        = string
}

variable "alb_acm_certificate_arn" {
  description = "ACM Certificate ARN for ALB HTTPS listener"
  type        = string
}

variable "alb_ssl_policy" {
  description = "TLS security policy for ALB HTTPS listener"
  type        = string
}

variable "asg_min_size" {
  description = "Minimum EC2 instances in ASG"
  type        = number
}

variable "asg_max_size" {
  description = "Maximum EC2 instances in ASG"
  type        = number
}

variable "asg_desired_capacity" {
  description = "Desired EC2 instances in ASG"
  type        = number
}

variable "scale_up_cpu_threshold" {
  description = "CPU percentage threshold for scaling up"
  type        = number
}

variable "scale_down_cpu_threshold" {
  description = "CPU percentage threshold for scaling down"
  type        = number
}

variable "alarm_period" {
  description = "CloudWatch alarm evaluation period in seconds"
  type        = number
}

variable "alarm_evaluation_periods" {
  description = "Number of evaluation periods before triggering alarm"
  type        = number
}

# CloudFront

variable "cf_acm_certificate_arn" {
  description = "ACM Certificate ARN (us-east-1) for CloudFront HTTPS"
  type        = string
}

variable "price_class" {
  description = "CloudFront distribution price class"
  type        = string
}
