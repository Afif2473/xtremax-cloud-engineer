variable "project_name" {
  description = "Project name used for resourcec naming and tagging"
  type        = string
}

variable "environment" {
  description = "Deploymemt environment"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "azs" {
  description = "List of availability zones for the subnets"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (ALB and NAT Gateway)"
  type        = list(string)
}

variable "private_app_subnet_cidrs" {
  description = "CIDR blocks for private application subnets (EC2 ASG)"
  type        = list(string)
}

variable "private_db_subnet_cidrs" {
  description = "CIDR blocks for isolated private database subnets (RDS)"
  type        = list(string)
}
