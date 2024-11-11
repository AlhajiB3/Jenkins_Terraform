# AWS region
variable "region" {
  description = "The AWS region to deploy resources in"
  default     = "us-east-1"
}

# Instance type for the EC2 instance
variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

# AMI ID for the Ubuntu server
variable "ami" {
  description = "AMI ID for the Ubuntu server"
  default     = "ami-063d43db0594b521b"
}

# SSH Key Pair name to access the instance
variable "key_name" {
  description = "Name of the SSH key pair"
}

# Allowed IP address to access the instance (replace with your IP)
variable "allowed_ip" {
  description = "Your IP address to allow SSH and Jenkins access"
}
