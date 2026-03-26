variable "project_name" { type = string }
variable "public_subnet_id" { type = string }
variable "security_group_id" { type = string }
variable "key_name" { type = string }

# Add this line so the module can receive the value from the root
variable "iam_instance_profile" {
  type        = string
  description = "The IAM instance profile name from the IAM module"
}
