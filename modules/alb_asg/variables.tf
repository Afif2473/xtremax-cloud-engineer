variable "project_name" {
  description = "Project name used for resource naming and tagging"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., dev, prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the ALB Target Group is created"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for the Application Load Balancer"
  type        = list(string)
}

variable "private_app_subnet_ids" {
  description = "Private application subnet IDs for the EC2 Auto Scaling Group"
  type        = list(string)
}

variable "alb_sg_id" {
  description = "Security Group ID for the ALB"
  type        = string
}

variable "ec2_sg_id" {
  description = "Security Group ID for the WordPress EC2 instances"
  type        = string
}

variable "iam_instance_profile_name" {
  description = "IAM Instance Profile name attached to EC2 instances"
  type        = string
}

variable "wordpress_ami_id" {
  description = "WordPress AMI ID (passed explicitly for offline planning)"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for WordPress servers"
  type        = string
}

variable "alb_acm_certificate_arn" {
  description = "ACM Certificate ARN for the ALB HTTPS listener"
  type        = string
}

variable "alb_ssl_policy" {
  description = "TLS/SSL security policy for the ALB HTTPS listener"
  type        = string
}

variable "asg_min_size" {
  description = "Minimum number of EC2 instances in the ASG"
  type        = number
}

variable "asg_max_size" {
  description = "Maximum number of EC2 instances in the ASG"
  type        = number
}

variable "asg_desired_capacity" {
  description = "Desired number of EC2 instances in the ASG"
  type        = number
}

variable "scale_up_cpu_threshold" {
  description = "CPU utilization percentage threshold to trigger scale up"
  type        = number
}

variable "scale_down_cpu_threshold" {
  description = "CPU utilization percentage threshold to trigger scale down"
  type        = number
}

variable "alarm_period" {
  description = "CloudWatch alarm evaluation period in seconds"
  type        = number
}

variable "alarm_evaluation_periods" {
  description = "Number of consecutive periods to evaluate before triggering alarm"
  type        = number
}

variable "db_endpoint" {
  description = "RDS MySQL endpoint for WordPress configuration"
  type        = string
}

variable "db_name" {
  description = "WordPress MySQL database name"
  type        = string
}
