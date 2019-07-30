name = "cxcloud-demo"

aws_region = "eu-west-1"

workspace_cidrs = {
  dev  = "10.24.0.0/16"
  prod = ""
}

openvpn_key_name = {
  dev  = "cxcloud-demo"
  prod = ""
}

openvpn_instance_type = {
  dev  = "t3a.nano"
  prod = ""
}

# E.g. 10.94.0.0/16 with extension bits 8 would result in 10.94.0.0/24
cdir_private_extension_bits = {
  dev  = 8
  prod = 4
}

cdir_public_extension_bits = {
  dev  = 8
  prod = 8
}

single_nat_gateway = {
  dev  = true
  prod = true
}

open_vpn_ami = {
  dev  = "ami-0cbf7a0c36bde57c9"
  prod = ""
}

hosted_zone = {
  dev  = "demo.cxcloud.com."
  prod = ""
}

certificate_domain_names = {
  dev = [
    "*.dev.demo.cxcloud.com",
    "*.demo.cxcloud.com",
    "demo.cxcloud.com"
  ]
  prod = []
}

# ELB alias DNS records
dns_loadblancer_records = {
  dev = [
    {
      host  = "*.dev.demo.cxcloud.com."
      alias = "internal-some-random-hash.eu-west-1.elb.amazonaws.com"
    },
    {
      host  = "staging.demo.cxcloud.com."
      alias = "some-random-hash.eu-west-1.elb.amazonaws.com"
    },
    {
      host  = "int-jenkins.demo.cxcloud.com."
      alias = "some-random-hash.eu-west-1.elb.amazonaws.com"
    },
    {
      host  = "int-sonar.demo.cxcloud.com."
      alias = "some-random-hash.eu-west-1.elb.amazonaws.com"
    }
  ]
  prod = []
}

# Just length of certificate_domain_names can't be used since domain names like
# cxcloud.com and *.cxcloud.com would use the same CNAME
# validation and terraform would fail to create all records due to dublications
certificate_validations = {
  dev  = 2
  prod = 0
}

ecr_repositories = [
  "cxcloud-images",
  "jenkins-master",
  "cxcloud-worker"
]
