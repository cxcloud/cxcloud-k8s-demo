# Terraform for CX Cloud Demo

## Requirements

- [Terraform](https://www.terraform.io/downloads.html)
- [Route53 Hosted Zone](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/CreatingHostedZone.html) on the AWS account for domain name hosting.

## Install the infra with Terraform

Review the settings in [terraform.tfvars](example_vars/terraform.tfvars) and redefine the variables.

Provision the infra by running:

```console
cd terraform
terraform init
terraform workspace new dev
terraform workspace select dev
terraform apply -var-file=example_vars/terraform.tfvars
```

Where `dev` can be `stg` or `prod` as well.

After the `apply` command is successfully run, Terraform will display some results which include all the information you need for the next steps, [Install OpenVPN](https://github.com/cxcloud/demo-cxcloud-k8s/blob/master/openvpn-ansible/README.md) and [Install Kubernetes](https://github.com/cxcloud/demo-cxcloud-k8s/blob/master/kubernetes/README.md). You can always get to them again by running `terraform output` or `terraform output -json`.

Note that the load balancers are created in the [Install Kubernetes](https://github.com/cxcloud/demo-cxcloud-k8s/blob/master/kubernetes/README.md) step. Hence, the [terraform.tfvars](example_vars/terraform.tfvars) need to be updated with the right URLs for the load balancers after the Kubernetes step is completed. Re-run the `terraform apply` command in order to update the domain name aliases.

The URL of the load balancer\(s\) is displayed after generating the infrastructure. But the URLs can also be retrieved using:

```console
kubectl get ingress --all-namespaces
```
