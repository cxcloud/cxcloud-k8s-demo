output "arn" {
  description = "ARN to ACM certificate"
  value       = aws_acm_certificate.cert.arn
}
