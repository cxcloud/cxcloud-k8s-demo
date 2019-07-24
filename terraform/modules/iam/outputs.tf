output "instance_profile" {
  description = "ARN for instance profile"
  value       = aws_iam_instance_profile.kops_nodes.arn
}

output "kops_role_id" {
  description = "Id for the kops IAM role"
  value       = aws_iam_role.kops_nodes.id
}

output "kops_role_arn" {
  description = "ARN for the kops IAM role"
  value       = aws_iam_role.kops_nodes.arn
}
