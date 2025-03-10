# Create KMS key for EFS encryption
resource "aws_kms_key" "efs_kms_key" {
  description             = "KMS key for EFS encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-efs-kms-key"
    }
  )
}

# Create alias for the KMS key
resource "aws_kms_alias" "efs_kms_alias" {
  name          = "alias/${var.environment}-efs-kms-key"
  target_key_id = aws_kms_key.efs_kms_key.key_id

  depends_on = [aws_kms_key.efs_kms_key] # Ensures KMS key is created first
}


# Create EFS file system
resource "aws_efs_file_system" "efs" {
  creation_token = "${var.environment}-efs"
  encrypted      = true
  kms_key_id     = aws_kms_key.efs_kms_key.arn

  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-efs"
    }
  )
}


# Create mount target for the EFS in the first private subnet
resource "aws_efs_mount_target" "efs_mount_targets_1" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = aws_subnet.private[0].id
  security_groups = [aws_security_group.datalayer_sg.id]
}


# Create mount target for the EFS in the second private subnet
resource "aws_efs_mount_target" "efs_mount_targets_2" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = aws_subnet.private[1].id
  security_groups = [aws_security_group.datalayer_sg.id]
}

# Create EFS access point for wordpress application
resource "aws_efs_access_point" "wordpress_ap" {
  file_system_id = aws_efs_file_system.efs.id

  posix_user {
    gid = 1000
    uid = 1000
  }

  root_directory {
    path = "/wordpress"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "755"
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-wordpress-ap"
    }
  )
}

# Create EFS access point for wordpress application
resource "aws_efs_access_point" "tooling_ap" {
  file_system_id = aws_efs_file_system.efs.id

  posix_user {
    gid = 1000
    uid = 1000
  }

  root_directory {
    path = "/tooling"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "755"
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-tooling-ap"
    }
  )
}