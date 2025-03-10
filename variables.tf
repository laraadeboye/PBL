variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "enable_dns_support" {
  type        = bool
  description = "Enable DNS support in the VPC"
  default     = true
}

variable "enable_dns_hostnames" {
  type        = bool
  description = "Enable DNS hostnames in the VPC"
  default     = true
}

variable "preferred_number_of_public_subnets" {
  type        = number
  description = "Number of public subnets to create. If null, two subnets will be created by default."
  default     = 2
}

variable "preferred_number_of_private_subnets" {
  type        = number
  description = "Number of private subnets to create. If null, one subnet per AZ will be created."
  default     = 4
}

variable "environment" {
  type        = string
  description = "Environment name (dev/staging/production)"
  default     = "dev"
}

variable "tags" {
  description = "A mapping of tags to assign to all resources"
  type        = map(string)
  default = {
    Terraform = "true"
    Owner     = "DevOps Team"
    project   = "laraadeboye"
  }
}

variable "public_subnet_type" {
  type        = string
  description = "Type tag for public subnets"
  default     = "Public"
}

variable "private_subnet_type" {
  type        = string
  description = "Type tag for private subnets"
  default     = "Private"
}

variable "notification_email" {
  description = "The email address to receive ASG notifications"
  type        = string
  default     = ""
}

variable "bastion_instance_type" {
  description = "The instance type for the bastion host"
  type        = string
  default     = "t2.small"
}


variable "nginx_instance_type" {
  description = "The instance type for the bastion host"
  type        = string
  default     = "t2.small"
}

variable "webserver_instance_type" {
  description = "The instance type for the bastion host"
  type        = string
  default     = "t2.small"
}

variable "ami" {
  description = "Ami taken from aws console"
  type        = string
  default     = ""
}

variable "public_key_location" {
  description = "The location of the ssh key on developer's workstation"
  type        = string
}

# Bastion Auto Scaling configuration
variable "bastion_desired_capacity" {
  description = "The desired number of bastion instances"
  type        = number
  default     = 1
}

variable "bastion_min_size" {
  description = "The minimum number of bastion instances"
  type        = number
  default     = 1
}

variable "bastion_max_size" {
  description = "The maximum number of bastion instances"
  type        = number
  default     = 2
}

variable "domain_name" {
  description = "Domain name "
  type        = string
  default     = "laraadeboye.com"
}

# Nginx Auto Scaling configuration
variable "nginx_desired_capacity" {
  description = "The desired number of bastion instances"
  type        = number
  default     = 1
}

variable "nginx_min_size" {
  description = "The minimum number of bastion instances"
  type        = number
  default     = 1
}

variable "nginx_max_size" {
  description = "The maximum number of bastion instances"
  type        = number
  default     = 2
}

# Wordpress webserver Auto Scaling configuration
variable "wordpress_desired_capacity" {
  description = "The desired number of bastion instances"
  type        = number
  default     = 1
}

variable "wordpress_min_size" {
  description = "The minimum number of bastion instances"
  type        = number
  default     = 1
}

variable "wordpress_max_size" {
  description = "The maximum number of bastion instances"
  type        = number
  default     = 2
}

# Tooling webserver Auto Scaling configuration
variable "tooling_desired_capacity" {
  description = "The desired number of bastion instances"
  type        = number
  default     = 1
}

variable "tooling_min_size" {
  description = "The minimum number of bastion instances"
  type        = number
  default     = 1
}

variable "tooling_max_size" {
  description = "The maximum number of bastion instances"
  type        = number
  default     = 2
}

variable "rds_username" {
  type        = string
  description = "Database username"
  default     = ""
}

variable "rds_database_name" {
  type        = string
  description = "Database name"
  default     = ""
}

variable "rds_instance_class" {
  type        = string
  description = "Db instance class"
  default     = ""
}

variable "rds_max_allocated_storage" {
  type        = number
  description = "Max storage allocated to db"
  default     = 50
}

variable "rds_allocated_storage" {
  type        = number
  description = "storage allocated to db"
  default     = 20
}
