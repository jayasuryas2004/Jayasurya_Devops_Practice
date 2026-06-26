output "irsa_role_arn" {
  description = "The ARN of the IAM Role to annotate in the Kubernetes Service Account"
  value       = aws_iam_role.irsa_dynamodb_role.arn
}