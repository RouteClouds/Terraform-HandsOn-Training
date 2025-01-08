output "database_endpoint" {
  description = "Database endpoint"
  value       = aws_db_instance.example.endpoint
}

output "database_name" {
  description = "Database name"
  value       = aws_db_instance.example.db_name
}

output "secret_arn" {
  description = "ARN of the secret in Secrets Manager"
  value       = aws_secretsmanager_secret.database.arn
}

output "connection_details" {
  description = "Database connection details"
  value = {
    endpoint = aws_db_instance.example.endpoint
    port     = aws_db_instance.example.port
    dbname   = aws_db_instance.example.db_name
  }
  sensitive = true
} 