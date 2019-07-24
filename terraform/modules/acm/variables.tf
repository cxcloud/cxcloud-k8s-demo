variable "hosted_zone" {
  type = string
}

variable "certificate_domain_names" {
  type = list(string)
}

variable "certificate_validations" {
  type = number
}
