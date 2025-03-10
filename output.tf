# Output the RDS endpoint
output "rds_endpoint" {
  description = "The endpoint of the RDS instance"
  value       = aws_db_instance.mysql.endpoint
}

# Output the Secrets Manager secret ARN
output "rds_secret_arn" {
  description = "The ARN of the Secrets Manager secret storing RDS credentials"
  value       = aws_secretsmanager_secret.rds_secret.arn
}