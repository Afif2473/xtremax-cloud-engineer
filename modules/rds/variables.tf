variable "project_name" {
  description = "Project name used for resource naming and tagging"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "private_db_subnet_ids" {
  description = "List of isolated private DB subnet IDs for the DB Subnet Group"
  type        = list(string)
}

variable "rds_sg_id" {
  description = "Security Group ID allowing MySQL access only from EC2"
  type        = string
}

variable "db_name" {
  description = "Initial MySQL database name for WordPress"
  type        = string
}

variable "db_username" {
  description = "Master username for the RDS MySQL instance"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Master password for the RDS MySQL instance"
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
  description = "Allocated storage in GiB"
  type        = number
}

variable "multi_az" {
  description = "Enable Multi-AZ deployment for high availability"
  type        = bool
}

variable "backup_retention_period" {
  description = "Number of days to retain automated backups"
  type        = number
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on DB deletion"
  type        = bool
}

variable "deletion_protection" {
  description = "Enable deletion protection on the RDS instance"
  type        = bool
}
