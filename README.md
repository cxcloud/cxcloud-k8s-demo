# CX Cloud Demo Infrastructure

## Usage

Review your settings in `terraform.tfvars` then run:

```sh
cd terraform
terraform init
terraform workspace select dev
terraform apply
```

Where `dev` can be `staging` or `production` as well.

After the `apply` command is successfully run, Terraform will display some results which include all the information you need for the next step. You can always get to them again by running `terraform output` or `terraform output -json`.

## Install Kubernetes

kops was selected for installing the Kubernetes cluster on top of AWS. The setup differs a bit between environments, hence, different instructions sections. Some parts of the kops installation process has to be done manually.

### Dev / Staging

- Create the cluster. Replace the received values from Terraform in the following command and run it (you need to have Kops installed):

```sh
kops create cluster \
  --name=cxcloud-demo-dev.k8s.local \
  --state=s3://cxcloud-demo-dev-kops-state \
  --image=kope.io/k8s-1.11-debian-stretch-amd64-hvm-ebs-2018-08-17 \
  --zones=eu-west-1a,eu-west-1b,eu-west-1c \
  --master-size=t3.medium \
  --node-size=t3.large \
  --node-count=1 \
  --ssh-public-key=~/.ssh/sandbox-jarl.pub \
  --associate-public-ip=false \
  --topology=private \
  --dns=private \
  --api-loadbalancer-type=internal \
  --networking=weave \
  --vpc=TERRAFORM_VPC_ID \
  --network-cidr=TERRAFORM_VPC_CIDR_BLOCK \
  --subnets=TERRAFORM_PRIVATE_SUBNET_0,TERRAFORM_PRIVATE_SUBNET_1,TERRAFORM_PRIVATE_SUBNET_2 \
  --utility-subnets=TERRAFORM_PUBLIC_SUBNET_0,TERRAFORM_PUBLIC_SUBNET_1,TERRAFORM_PUBLIC_SUBNET_2 \
  --yes
```

- Edit instance group, nodes

```sh
kops edit ig nodes --state=s3://cxcloud-demo-dev-kops-state
```

- Modify the subnets to only use `eu-west-1b` and the instance profile to the template. The spec section of the template should look something like this:

```sh
spec:
.... other specs ...
  subnets:
  - eu-west-1b
  iam:
    profile: arn:aws:iam::12345678901:instance-profile/kops-nodes
```

- Create new instance group, application (it will open an editor were manual changes has to be done)

```sh
kops create ig application --state=s3://cxcloud-demo-dev-kops-state
```

- Change instance type to m4.large and modify maxSize to 10 and minSize to 2. Also add the exact same `iam` section to `spec` as for instance group nodes above. Make sure the the image in use is `kope.io/k8s-1.11-debian-stretch-amd64-hvm-ebs-2018-08-17`. We use spot instances for dev/staging so add `maxPrice: "0.112"`.

The spec section of the template should look something like this:

```sh
spec:
.... other specs ...
  image: kope.io/k8s-1.11-debian-stretch-amd64-hvm-ebs-2018-08-17
  maxPrice: "0.112"
  iam:
    profile: arn:aws:iam::12345678901:instance-profile/kops-nodes
```

- Update the cluster and perform a rolling update for the cluster

```sh
kops update cluster cxcloud-demo-dev.k8s.local --state=s3://cxcloud-demo-dev-kops-state --yes
kops rolling-update cluster cxcloud-demo-dev.k8s.local --state=s3://cxcloud-demo-dev-kops-state --yes
```

- Run the installation script

```sh
cd kubernetes
./install.sh -e dev -c cxcloud-demo-dev.k8s.local -i nginx -a TERRAFORM_ACM_ARN
```

### CI/CD

To Install the CI/CD pipeline, please, refer to the [Jenkins repository](https://github.com/cxcloud/jenkins).
