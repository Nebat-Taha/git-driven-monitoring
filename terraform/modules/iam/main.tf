# terraform/modules/iam/main.tf

# 1. Define the Trust Policy (Who can use this role?)
resource "aws_iam_role" "prometheus_role" {
  name = "${var.project_name}-prometheus-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

# 2. Attach the Policy (What can this role do?)
resource "aws_iam_role_policy_attachment" "read_only" {
  role       = aws_iam_role.prometheus_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

# 3. Create the Instance Profile (The "Bridge" to EC2)
resource "aws_iam_instance_profile" "prometheus_profile" {
  name = "${var.project_name}-prometheus-profile"
  role = aws_iam_role.prometheus_role.name
}
