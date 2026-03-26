# outputs.tf
output "instance_profile_name" {
  value = aws_iam_instance_profile.prometheus_profile.name
}
