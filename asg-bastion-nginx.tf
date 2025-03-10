# Create an SNS topic for ASG notifications
resource "aws_sns_topic" "asg_notifications" {
  name = "${var.environment}-asg-notifications"

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-asg-notifications"
    }
  )
}

# Create SNS topic subscription (email)
resource "aws_sns_topic_subscription" "asg_notifications_email" {
  count     = var.notification_email != "" ? 1 : 0 # conditionally create the email notificaton only if the email is set
  topic_arn = aws_sns_topic.asg_notifications.arn
  protocol  = "email"
  endpoint  = var.notification_email
}


resource "aws_key_pair" "ssh_key" {
  key_name   = "dev-key"
  public_key = file(var.public_key_location)

  tags = {
    Name = "${var.environment}-key-pair"
  }
}

# Create a launch template for bastion
resource "aws_launch_template" "bastion_launch_template" {
  name                   = "${var.environment}-bastion-launch-template"
  image_id               = var.ami
  instance_type          = var.bastion_instance_type
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  key_name               = aws_key_pair.ssh_key.key_name
  user_data              = base64encode(templatefile("${path.module}/userdata/bastion.sh", {}))


  tag_specifications {
    resource_type = "instance"
    tags = merge(
      var.tags,
      {
        Name = "${var.environment}-bastion"
      }
    )
  }


  lifecycle {
    create_before_destroy = true
  }
}

# Create ASG for bastion
resource "aws_autoscaling_group" "bastion_asg" {
  name                = "${var.environment}-bastion-asg"
  desired_capacity    = var.bastion_desired_capacity
  max_size            = var.bastion_max_size
  min_size            = var.bastion_min_size
  vpc_zone_identifier = [aws_subnet.public[0].id, aws_subnet.public[1].id]

  launch_template {
    id      = aws_launch_template.bastion_launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.environment}-bastion"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

# Create a launch template for Nginx
resource "aws_launch_template" "nginx_launch_template" {
  name                   = "${var.environment}-nginx-launch-template"
  image_id               = var.ami
  instance_type          = var.nginx_instance_type
  vpc_security_group_ids = [aws_security_group.nginx_sg.id]
  key_name               = aws_key_pair.ssh_key.key_name
  user_data = base64encode(templatefile("${path.module}/userdata/nginx.sh", {
    domain_name = var.domain_name
  }))


  tag_specifications {
    resource_type = "instance"
    tags = merge(
      var.tags,
      {
        Name = "${var.environment}-nginx"
      }
    )
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Create ASG for Nginx
resource "aws_autoscaling_group" "nginx_asg" {
  name                      = "${var.environment}-nginx-asg"
  desired_capacity          = var.nginx_desired_capacity
  max_size                  = var.nginx_max_size
  min_size                  = var.nginx_min_size
  vpc_zone_identifier       = [aws_subnet.public[0].id, aws_subnet.public[1].id]
  target_group_arns         = [aws_lb_target_group.nginx_tgt.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.nginx_launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.environment}-nginx"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

# Connect ASGs to SNS topic for notifications
resource "aws_autoscaling_notification" "asg_notifications" {
  group_names = [
    aws_autoscaling_group.bastion_asg.name,
    aws_autoscaling_group.nginx_asg.name,
    aws_autoscaling_group.wordpress_asg.name,
    aws_autoscaling_group.tooling_asg.name
  ]

  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR"
  ]

  topic_arn = aws_sns_topic.asg_notifications.arn
}

