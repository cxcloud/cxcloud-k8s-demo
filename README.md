# CX Cloud Demo Infrastructure

The demo setup will install the infra with Kubernetes running on AWS. When the setup is up and running it can be used for the [CX Cloud Demo app](https://github.com/cxcloud/cxcloud-monorepo-angular) or any other CX Cloud related project.

## Getting stated with CX Cloud Demo

### Requirements

- [Terraform](https://www.terraform.io/downloads.html) is used for provisioning all AWS required services for running the demo application on Kubernetes.
- [Kops](https://github.com/kubernetes/kops#installing) is used for installing Kubernetes on AWS.
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) is requred in order to automatically install the OpenVPN software on a instance provisioned.

### Installation steps

There are few steps that has to be done in order to install the infrastructure. Follow the instructions from the following steps:

1) [Provision the infra](terraform).
2) [Install OpenVPN](openvpn-ansible) in order to access services in the private subnets on AWS.
3) [Install Kubernetes](kubernetes).

### CI/CD

To Install the CI/CD pipeline, please, refer to the [Jenkins repository](https://github.com/cxcloud/jenkins).

#### SonarQube

SonarQube can be installed with the following commands:

```sh
kubectl apply -f kubernetes/pvc-sonar.yaml
helm install stable/sonarqube --name sonar --namespace ci -f kubernetes/sonar.yaml
````
