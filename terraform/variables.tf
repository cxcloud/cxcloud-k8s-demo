variable "name" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "workspace_cidrs" {
  type = map(string)
}

variable "openvpn_key_name" {
  type = map(string)
}

variable "openvpn_instance_type" {
  type = map(string)
}

variable "cdir_private_extension_bits" {
  type = map(string)
}

variable "cdir_public_extension_bits" {
  type = map(string)
}

variable "single_nat_gateway" {
  type = map(string)
}

variable "open_vpn_ami" {
  type = map(string)
}

variable "hosted_zone" {
  type = map(string)
}

variable "certificate_domain_names" {
  type = map(list(string))
}

variable "certificate_validations" {
  type = map(number)
}

variable "dns_loadblancer_records" {
  type = map(list(map(string)))
}

variable "ecr_repositories" {
  type = list(string)
}
