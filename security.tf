# security group for external alb
resource "aws_security_group" "ext_alb_sg" {
  name        = "ext-alb-sg"
  vpc_id      = aws_vpc.main.id
  description = "Allow TLS inbound traffic"

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-ext_alb_sg"
    }
  )
}

# security group for bastion to allow ssh access into the bastion host from your ip
resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  vpc_id      = aws_vpc.main.id
  description = "Allow incoming SSH connections"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-bastion_sg"
    }
  )
}

# nginx security group with egress rule
resource "aws_security_group" "nginx_sg" {
  name        = "nginx-sg"
  vpc_id      = aws_vpc.main.id
  description = "Allow inbound traffic for nginx"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-nginx_sg"
    }
  )
}

# Ingress rules using aws_security_group_rule
resource "aws_security_group_rule" "inbound_http_nginx" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ext_alb_sg.id
  security_group_id        = aws_security_group.nginx_sg.id
  description              = "HTTP from external ALB"
}

resource "aws_security_group_rule" "inbound_https_nginx" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ext_alb_sg.id
  security_group_id        = aws_security_group.nginx_sg.id
  description              = "HTTPS from external ALB"
}

resource "aws_security_group_rule" "inbound_bastion_ssh" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion_sg.id
  security_group_id        = aws_security_group.nginx_sg.id
  description              = "SSH from bastion host"
}

# security group for internal alb
resource "aws_security_group" "int_alb_sg" {
  name        = "int-alb-sg"
  vpc_id      = aws_vpc.main.id
  description = "Allow traffic for internal ALB"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-int_alb_sg"
    }
  )
}

resource "aws_security_group_rule" "int_alb_https" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.nginx_sg.id
  security_group_id        = aws_security_group.int_alb_sg.id
  description              = "HTTPS from nginx"
}
# security group for webservers
resource "aws_security_group" "webserver_sg" {
  name        = "webserver-sg"
  vpc_id      = aws_vpc.main.id
  description = "Allow inbound traffic for webservers"


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-webserver_sg"
    }
  )
}

resource "aws_security_group_rule" "inbound_web_https" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.int_alb_sg.id
  security_group_id        = aws_security_group.webserver_sg.id
  description              = "HTTPS from external ALB"
}

resource "aws_security_group_rule" "inbound_web_ssh" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion_sg.id
  security_group_id        = aws_security_group.webserver_sg.id
  description              = "SSH from bastion host"
}

# security group for datalayer
resource "aws_security_group" "datalayer_sg" {
  name        = "datalayer_sg"
  vpc_id      = aws_vpc.main.id
  description = "Allow inbound traffic for data layer"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-datalayer-sg"
    }
  )
}

resource "aws_security_group_rule" "inbound_nfs_port" {
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.webserver_sg.id
  security_group_id        = aws_security_group.datalayer_sg.id
  description              = "inbound traffic on NFS port"
}

resource "aws_security_group_rule" "inbound_mysql_webserver" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.webserver_sg.id
  security_group_id        = aws_security_group.datalayer_sg.id
  description              = "inbound traffic on mysql port from webserver"
}

resource "aws_security_group_rule" "inbound_mysql_bastion" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion_sg.id
  security_group_id        = aws_security_group.datalayer_sg.id
  description              = "inbound traffic on mysql port from bastion host"
}