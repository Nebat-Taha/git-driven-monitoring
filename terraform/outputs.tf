# terraform/outputs.tf

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_id" {
  value = module.vpc.public_subnet_id
}



output "prometheus_public_ip" {
  description = "The public IP address of the Prometheus server"
  value       = module.ec2.instance_public_ip
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}
