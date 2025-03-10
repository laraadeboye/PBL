# Create AssumeRole
resource "aws_iam_role" "ec2_instance_role" {
  name = "ec2_instance_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-assume-role"
    }
  )
}

# Create IAM policy for this role
resource "aws_iam_policy" "policy" {
  name        = "ec2_instance_policy"
  description = "A policy that allows EC2 instances to perform specific actions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:Describe*"
        ]
        Resource = "*"
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-instance-policy"
    }
  )
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "policy_attach" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = aws_iam_policy.policy.arn
}

# Create an instance profile
resource "aws_iam_instance_profile" "ip" {
  name = "aws_instance_profile_ip"
  role = aws_iam_role.ec2_instance_role.name

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-instance-profile"
    }
  )
}
