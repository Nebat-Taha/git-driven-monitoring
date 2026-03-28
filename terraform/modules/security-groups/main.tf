# terraform/modules/security-groups/main.tf

resource "aws_security_group" "prometheus_sg" {
  name        = "${var.project_name}-prometheus-sg"
  description = "Allow monitoring and management traffic"
  vpc_id      = var.vpc_id

  # SSH for Ansible (from GitHub Runners)
  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Prometheus UI (Restricted to your IP)
  ingress {
    description = "Prometheus UI"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = [var.allowed_mgmt_ip]
  }

  # Node Exporter (Internal VPC scraping)
  ingress {
    from_port   = 8000
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # Outbound: Allow everything (needed to scrape targets & download updates)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-prometheus-sg"
  }
}
