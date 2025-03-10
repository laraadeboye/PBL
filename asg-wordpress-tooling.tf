# Create a launch template for wordpress
resource "aws_launch_template" "wordpress_launch_template" {
  name                   = "${var.environment}-wordpress-launch-template"
  image_id               = var.ami
  instance_type          = var.webserver_instance_type
  vpc_security_group_ids = [aws_security_group.webserver_sg.id]
  key_name               = aws_key_pair.ssh_key.key_name
  user_data              = base64encode(templatefile("${path.module}/userdata/wordpress.sh", {}))


  tag_specifications {
    resource_type = "instance"
    tags = merge(
      var.tags,
      {
        Name = "${var.environment}-wordpress"
      }
    )
  }


  lifecycle {
    create_before_destroy = true
  }
}

# Create ASG for wordpress webserver
resource "aws_autoscaling_group" "wordpress_asg" {
  name                      = "${var.environment}-wordpress-asg"
  desired_capacity          = var.wordpress_desired_capacity
  max_size                  = var.wordpress_max_size
  min_size                  = var.wordpress_min_size
  vpc_zone_identifier       = [aws_subnet.private[0].id, aws_subnet.private[1].id]  
  target_group_arns         = [aws_lb_target_group.wordpress_tgt.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.wordpress_launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.environment}-wordpress"
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

# Create a launch template for Tooling
resource "aws_launch_template" "tooling_launch_template" {
  name                   = "${var.environment}-tooling-launch-template"
  image_id               = var.ami
  instance_type          = var.webserver_instance_type
  vpc_security_group_ids = [aws_security_group.webserver_sg.id]
  key_name               = aws_key_pair.ssh_key.key_name
  user_data              = base64encode(templatefile("${path.module}/userdata/tooling.sh", {}))


  tag_specifications {
    resource_type = "instance"
    tags = merge(
      var.tags,
      {
        Name = "${var.environment}-tooling"
      }
    )
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Create ASG for wordpress
resource "aws_autoscaling_group" "tooling_asg" {
  name                      = "${var.environment}-tooling-asg"
  desired_capacity          = var.tooling_desired_capacity
  max_size                  = var.tooling_max_size
  min_size                  = var.tooling_min_size
  vpc_zone_identifier       = [aws_subnet.private[0].id, aws_subnet.private[1].id]
  target_group_arns         = [aws_lb_target_group.tooling_tgt.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.tooling_launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.environment}-tooling"
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

