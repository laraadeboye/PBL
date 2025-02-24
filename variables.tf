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
  description = "Environment name (dev/staging/prod)"
  default     = "dev"
}

variable "tags" {
  description = "A mapping of tags to assign to all resources"
  type        = map(string)
  default = {
    Terraform   = "true"
    Environment = "dev"
    Owner       = "DevOps Team"
    project     = "laraadeboye"
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