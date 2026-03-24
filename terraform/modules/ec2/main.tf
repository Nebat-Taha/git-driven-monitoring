# terraform/modules/ec2/main.tf

# Get the latest Ubuntu 24.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Official AWS Account ID for Canonical, the company that creates and maintains Ubuntu.

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

resource "aws_instance" "prometheus_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.key_name

  # This tag is CRITICAL for your Ansible Dynamic Inventory
  tags = {
    Name    = "${var.project_name}-prometheus"
    Project = var.project_name
    Role    = "monitoring-server"
  }

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
  }
}
