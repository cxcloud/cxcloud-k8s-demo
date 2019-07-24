# Route 53 Hosted Zone
data "aws_route53_zone" "zone" {
  name         = var.hosted_zone
  private_zone = false
}

# TSL Certificate witch domain name verification
resource "aws_acm_certificate" "cert" {
  domain_name               = element(var.certificate_domain_names, 0)
  subject_alternative_names = compact(split(",", length(var.certificate_domain_names) == 1 ? "" : join(",", slice(var.certificate_domain_names, 1, length(var.certificate_domain_names), ), ), ), )
  validation_method         = "DNS"
  tags = {
    Environment = "Demo"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "certificate_validations" {
  count   = var.certificate_validations
  zone_id = data.aws_route53_zone.zone.id
  name    = aws_acm_certificate.cert.domain_validation_options[count.index]["resource_record_name"]
  type    = aws_acm_certificate.cert.domain_validation_options[count.index]["resource_record_type"]
  records = [aws_acm_certificate.cert.domain_validation_options[count.index]["resource_record_value"]]
  ttl     = "3600"
}
