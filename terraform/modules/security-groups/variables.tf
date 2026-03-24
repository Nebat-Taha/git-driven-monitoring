variable "vpc_id" {
  type = string
}

variable "project_name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "allowed_mgmt_ip" {
  description = "Your public IP address for SSH and UI access (e.g., 1.2.3.4/32)"
  type        = string
}
