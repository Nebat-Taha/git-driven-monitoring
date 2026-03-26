# terraform/variables.tf
variable "aws_region" {
  description = "The AWS region to deploy resources into"
  type        = string
  default     = "us-east-1"
}
variable "my_ip" {
  description = "Your current public IP (e.g., 1.2.3.4/32)"
  type        = string
}

