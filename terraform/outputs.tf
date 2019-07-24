output "public_subnets" {
  description = "List of IDs of public route tables"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "List of IDs of private route tables"
  value       = module.vpc.private_subnets
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "availability_zones" {
  description = "AWS Availability Zones"
  value       = data.aws_availability_zones.available.names
}

output "vpn_ip" {
  description = "OpenVPN IP address"
  value       = module.openvpn.public_ip
}

output "ecr_addresses" {
  description = "ECR Repository URLs"
  value       = aws_ecr_repository.ecr.*.repository_url
}

output "kops_bucket_address" {
  description = "Kops Bucket Address"
  value       = "s3://${aws_s3_bucket.kops_s3_bucket.bucket}"
}

output "certificate_arn" {
  description = "ARN to ACM certificate"
  value       = module.acm_certificates.arn
}

output "instance_profile" {
  description = "ARN for instance profile"
  value       = module.iam_polices.instance_profile
}

output "es_endpoint" {
  description = "Elasticsearch Endpoint"
  value       = module.kinesis-firehose-elasticsearch.endpoint
}

output "kibana_url" {
  description = "Kibana Url"
  value       = "https://${module.kinesis-firehose-elasticsearch.endpoint}/_plugin/kibana/"
}
