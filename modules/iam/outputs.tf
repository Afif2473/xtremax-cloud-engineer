output "ec2_iam_role_arn" {
  description = "ARN of the IAM role for WordPress EC2 instances"
  value       = aws_iam_role.ec2.arn
}

output "ec2_iam_role_name" {
  description = "Name of the IAM role for WordPress EC2 instances"
  value       = aws_iam_role.ec2.name
}

output "ec2_instance_profile_name" {
  description = "Name of the IAM instance profile attached to EC2 instances"
  value       = aws_iam_instance_profile.ec2.name
}
