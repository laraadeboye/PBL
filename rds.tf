# Create KMS key for RDS encryption
resource "aws_kms_key" "rds_kms_key" {
  description             = "KMS key for RDS encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-rds-kms-key"
    }
  )
}

# Create alias for the RDS KMS key
resource "aws_kms_alias" "rds_kms_alias" {
  name          = "alias/${var.environment}-rds-key"
  target_key_id = aws_kms_key.rds_kms_key.key_id
}

# Create DB subnet group
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.environment}-rds-subnet-group"
  subnet_ids = [aws_subnet.private[2].id, aws_subnet.private[3].id]

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-rds-subnet-group"
    }
  )
}

# Create DB parameter group
resource "aws_db_parameter_group" "mysql_param_group" {
  name   = "${var.environment}-mysql-params"
  family = "mysql8.0"

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "collation_server"
    value = "utf8mb4_unicode_ci"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-mysql-params"
    }
  )
}

# Generate random password for RDS
resource "random_password" "rds_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Store RDS password in AWS Secrets Manager
resource "aws_secretsmanager_secret" "rds_secret" {
  name        = "${var.environment}-rds-credentials"
  description = "RDS MySQL credentials"
  kms_key_id  = aws_kms_key.rds_kms_key.arn

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-rds-credentials"
    }
  )
}

resource "aws_secretsmanager_secret_version" "rds_secret_version" {
  secret_id = aws_secretsmanager_secret.rds_secret.id
  secret_string = jsonencode({
    username = var.rds_username
    password = random_password.rds_password.result
    engine   = "mysql"
    host     = aws_db_instance.mysql.address
    port     = 3306
    dbname   = var.rds_database_name
  })

  # Depends on the RDS instance to ensure the host is available
  depends_on = [aws_db_instance.mysql]
}

# Create RDS MySQL instance
resource "aws_db_instance" "mysql" {
  identifier            = "${var.environment}-mysql"
  engine                = "mysql"
  engine_version        = "8.0"
  instance_class        = var.rds_instance_class
  allocated_storage     = var.rds_allocated_storage
  max_allocated_storage = var.rds_max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true
  kms_key_id            = aws_kms_key.rds_kms_key.arn

  db_name                = var.rds_database_name
  username               = var.rds_username
  password               = random_password.rds_password.result
  vpc_security_group_ids = [aws_security_group.datalayer_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  parameter_group_name   = aws_db_parameter_group.mysql_param_group.name

  multi_az                  = var.environment == "production" ? true : false
  publicly_accessible       = false
  skip_final_snapshot       = var.environment == "production" ? false : true
  final_snapshot_identifier = var.environment == "production" ? "${var.environment}-mysql-final-snapshot" : null
  deletion_protection       = var.environment == "production" ? true : false

  backup_retention_period = var.environment == "production" ? 7 : 1
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:30-sun:05:30"

  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]

  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  performance_insights_kms_key_id       = aws_kms_key.rds_kms_key.arn

  auto_minor_version_upgrade = true

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-mysql"
    }
  )

  # Prevent password from showing in terraform plan/apply output
  lifecycle {
    ignore_changes = [password]
  }
}
