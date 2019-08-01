# Kubernetes cluster for CX Cloud Demo

## Install Kubernetes

For this demo kops is used for installing the Kubernetes cluster on top of AWS. Some parts of the kops installation process has to be done manually.

Make sure that the [latest version of kops](https://github.com/kubernetes/kops#installing) is installed on the local machine.

### Dev / Staging

- Create the cluster. Replace the received values from Terraform in the following command and run it (you need to have Kops installed). The terraform variables was outputted from the terraform setup:

```sh
kops create cluster \
  --name=cxcloud-demo-dev.k8s.local \
  --state=s3://cxcloud-demo-dev-kops-state \
  --image=kope.io/k8s-1.12-debian-stretch-amd64-hvm-ebs-2019-05-13 \
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

- Change instance type to m4.large and modify maxSize to 10 and minSize to 2. Also add the exact same `iam` section to `spec` as for instance group nodes above. Make sure the the image in use is `kope.io/k8s-1.12-debian-stretch-amd64-hvm-ebs-2019-05-13`. We use spot instances for dev/staging so add `maxPrice: "0.112"`.

The spec section of the template should look something like this:

```sh
spec:
.... other specs ...
  image: kope.io/k8s-1.12-debian-stretch-amd64-hvm-ebs-2019-05-13
  maxPrice: "0.112"
  iam:
    profile: arn:aws:iam::12345678901:instance-profile/kops-nodes
```

- Update the cluster and perform a rolling update for the cluster

```sh
kops update cluster cxcloud-demo-dev.k8s.local --state=s3://cxcloud-demo-dev-kops-state --yes
kops rolling-update cluster cxcloud-demo-dev.k8s.local --state=s3://cxcloud-demo-dev-kops-state --yes
```

- Run the installation script, the ACM ARN is outputted form the terraform setup:

```sh
cd kubernetes
./install.sh -e dev -c cxcloud-demo-dev.k8s.local -i nginx -a TERRAFORM_ACM_ARN
```
