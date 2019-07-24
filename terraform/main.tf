# Local variables
locals {
  name_prefix              = "${var.name}-${terraform.workspace}"
  cidr                     = var.workspace_cidrs[terraform.workspace]
  extension_private_bits   = var.cdir_private_extension_bits[terraform.workspace]
  extension_public_bits    = var.cdir_public_extension_bits[terraform.workspace]
  certificate_domain_names = var.certificate_domain_names[terraform.workspace]
  dns_loadbalancer_records = var.dns_loadblancer_records[terraform.workspace]
}

# Provider
provider "aws" {
  region = var.aws_region
}

# Data Sources
data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}
data "aws_route53_zone" "zone" {
  name         = var.hosted_zone[terraform.workspace]
  private_zone = false
}
data "aws_elb_hosted_zone_id" "zone" {}

# VPC Module
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${local.name_prefix}-vpc"
  cidr = local.cidr

  azs = data.aws_availability_zones.available.names

  private_subnets = [
    cidrsubnet(local.cidr, local.extension_private_bits, 1),
    cidrsubnet(local.cidr, local.extension_private_bits, 3),
    cidrsubnet(local.cidr, local.extension_private_bits, 5),
  ]

  public_subnets = [
    cidrsubnet(local.cidr, local.extension_public_bits, 0),
    cidrsubnet(local.cidr, local.extension_public_bits, 2),
    cidrsubnet(local.cidr, local.extension_public_bits, 4),
  ]

  private_subnet_tags = {
    "SubnetType"                                           = "Private"
    "kubernetes.io/cluster/${local.name_prefix}.k8s.local" = "shared"
    "kubernetes.io/role/internal-elb"                      = "1"
  }

  public_subnet_tags = {
    "SubnetType"                                           = "Utility"
    "kubernetes.io/cluster/${local.name_prefix}.k8s.local" = "shared"
    "kubernetes.io/role/elb"                               = "1"
  }

  enable_nat_gateway = true
  single_nat_gateway = var.single_nat_gateway[terraform.workspace]

  tags = {
    Terraform   = "true"
    Environment = terraform.workspace
  }
}

# OpenVPN Module
module "openvpn" {
  source        = "github.com/tieto-cem/terraform-aws-openvpn?ref=v1.2.0"
  ami           = var.open_vpn_ami[terraform.workspace]
  region        = var.aws_region
  instance_type = var.openvpn_instance_type[terraform.workspace]
  key_name      = var.openvpn_key_name[terraform.workspace]
  vpc_id        = module.vpc.vpc_id
  subnet_id     = module.vpc.public_subnets[0]
  cidr          = local.cidr
  user_data     = ""
  tags = {
    Name = "OpenVPN"
  }
  volume_tags = {
    Name = "OpenVPN"
  }
}

# Kops State Bucket
resource "aws_s3_bucket" "kops_s3_bucket" {
  bucket = "${local.name_prefix}-kops-state"
  acl    = "private"
  tags = {
    Terraform = "true"
  }
}

# ECR repositories
resource "aws_ecr_repository" "ecr" {
  count = length(var.ecr_repositories)
  name  = var.ecr_repositories[count.index]
  tags = {
    Terraform   = "true"
    Environment = terraform.workspace
  }
}

# TSL Certificate witch domain name verification
module "acm_certificates" {
  source                   = "./modules/acm"
  hosted_zone              = var.hosted_zone[terraform.workspace]
  certificate_domain_names = local.certificate_domain_names
  certificate_validations  = var.certificate_validations[terraform.workspace]
}

# Application domain name alias records for LoadBlancers
resource "aws_route53_record" "application_domain_names" {
  count    = length(local.dns_loadbalancer_records)
  zone_id  = data.aws_route53_zone.zone.id
  name     = local.dns_loadbalancer_records[count.index]["host"]
  type     = "A"
  alias {
    name                   = local.dns_loadbalancer_records[count.index]["alias"]
    zone_id                = data.aws_elb_hosted_zone_id.zone.id
    evaluate_target_health = true
  }
}

# Kinesis Firehose and Elasticsearch module
module "kinesis-firehose-elasticsearch" {
  source                       = "github.com/cxcloud/terraform-kinesis-firehose-elasticsearch?ref=v1.1.0"
  region                       = var.aws_region
  es_name                      = "cxcloud"
  es_ver                       = 6.5
  es_instance_type             = "t2.small.elasticsearch"
  es_instance_count            = 1
  es_dedicated_master_enabled  = false
  es_ebs_size                  = 35
  es_snapshot_start_hour       = 23
  es_name_tag                  = "CX Cloud"
  es_whitelisted_ips           = ["${module.openvpn.public_ip}/32"]
  stream_name                  = "cxcloud"
  s3_bucket                    = "${local.name_prefix}-logging"
  s3_buffer_size               = 10
  s3_buffer_interval           = 60
  s3_compression_format        = "GZIP"
  es_index_name                = "cxcloud"
  es_type_name                 = "logs"
  es_buffering_size            = 10
  es_buffering_interval        = 60
  s3_backup_mode               = "AllDocuments"
  whitelisted_aws_account_arns = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
}

# IAM for kops nodes
module "iam_polices" {
  source = "./modules/iam"
}
