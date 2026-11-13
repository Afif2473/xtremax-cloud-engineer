output "db_instance_endpoint" {
  description = "Connection endpoint (host:port) for the RDS MySQL instance"
  value       = aws_db_instance.this.endpoint
}

output "db_instance_address" {
  description = "Hostname of the RDS MySQL instance"
  value       = aws_db_instance.this.address
}

output "db_name" {
  description = "Name of the WordPress database"
  value       = aws_db_instance.this.db_name
}
