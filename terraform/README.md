# Terraform for CX Cloud Demo

## Requirements

- [Terraform](https://www.terraform.io/downloads.html)

## Install the infra with Terraform

Review your settings in [terraform.tfvars](example_vars/terraform.tfvars) then run:

```sh
cd terraform
terraform init
terraform workspace select dev
terraform apply -var-file=example_vars/terraform.tfvars
```

Where `dev` can be `stg` or `prod` as well.

After the `apply` command is successfully run, Terraform will display some results which include all the information you need for the next step. You can always get to them again by running `terraform output` or `terraform output -json`.
