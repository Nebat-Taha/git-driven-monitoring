# terraform/oidc.tf

# 1. Create the OIDC Provider (Only needed once per AWS Account)
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"] # GitHub's official thumbprint
}

# 2. Create the Role for GitHub Actions
resource "aws_iam_role" "github_actions_role" {
  name = "github-actions-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Condition = {
          StringLike = {
            # ONLY allow your specific repo to use this role
            "token.actions.githubusercontent.com:sub" : "repo:your-username/git-driven-monitoring:*"
          }
        }
      }
    ]
  })
}

# 3. Attach Permissions (e.g., AdministratorAccess for testing)
resource "aws_iam_role_policy_attachment" "admin_access" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
