variable "project_name" {
  description = "Project name used for resource naming and tagging"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "ssm_db_param_arn" {
  description = "ARN of the SSM Parameter storing database configuration/credentials"
  type        = string
}

variable "log_group_arn" {
  description = "ARN pattern of the CloudWatch Log Group for EC2 WordPress logs"
  type        = string
}
