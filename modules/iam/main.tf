locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# EC2 IAM Role

resource "aws_iam_role" "ec2" {
  name = "${local.name_prefix}-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
  tags = {
    Name = "${local.name_prefix}-ec2-role"
  }
}

# 1. SSM Session Manager (secure management without SSH port 22)

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# 2. Least-privilege policy for reading DB config & writing CloudWatch logs

resource "aws_iam_role_policy" "ec2_least_privilege" {
  name = "${local.name_prefix}-ec2-least-privilege"
  role = aws_iam_role.ec2.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ReadDatabaseParameters"
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters"
        ]
        Resource = var.ssm_db_param_arn
      },
      {
        Sid    = "WriteWordPressLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = var.log_group_arn
      }
    ]
  })
}

# EC2 Instance Profile

resource "aws_iam_instance_profile" "ec2" {
  name = "${local.name_prefix}-ec2-instance-profile"
  role = aws_iam_role.ec2.name
  tags = {
    Name = "${local.name_prefix}-ec2-instance-profile"
  }
}
