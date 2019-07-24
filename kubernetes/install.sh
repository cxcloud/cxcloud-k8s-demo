#!/bin/bash

function help {
    printf "
This script will install all dependendencies needed for CX Cloud.

Usage:
    ./install.sh
    -a  ACM Certificate ARN
    -c  cluster name
    -i  Ingress controller (nginx or alb)
    -v  VPC ID
    -e  Environment (prod/dev)
    \n";
}

# Get parameters
INGRESS_CONTROLLER="-"
KUBE_ENV="-"
while getopts a:c:i:v:e: option; do
    case "${option}" in
        a) ACM_ARN=${OPTARG};;
        c) CLUSTER_NAME=${OPTARG};;
        i) INGRESS_CONTROLLER=${OPTARG};;
        v) VPC_ID=${OPTARG};;
        e) KUBE_ENV=${OPTARG};;
    esac
done

# Check for required parameters
if ([ ${INGRESS_CONTROLLER} != "nginx" ] && [ ${INGRESS_CONTROLLER} != "alb" ]) ||          # Ingess controller should be either nginx or alb
    ([ ${KUBE_ENV} != "dev" ] && [ ${KUBE_ENV} != "prod" ]) ||                              # Environment should be either dev or prod
    ([ ${INGRESS_CONTROLLER} == "alb" ] && ([ -z ${CLUSTER_NAME} ] || [ -z ${VPC_ID} ])) || # if alb, cluster name and vpc id has to be set
    ([ ${INGRESS_CONTROLLER} == "nginx" ] && [ -z ${ACM_ARN} ]); then                       # if nginx, ACM ARN has to be set
    help
    exit
fi

# RBAC
kubectl apply -f rbac.yaml

# Tilder
helm init --service-account tiller
sleep 20

# Metrics Service
helm install --name metrics-server --namespace kube-system -f metrics-service.yaml stable/metrics-server

# Install ingress controller
if [ ${INGRESS_CONTROLLER} == "nginx" ]; then
  #Internal Nginx controller
  helm install stable/nginx-ingress --name nginx-ingress --namespace kube-system \
    --set rbac.create=true \
    --set controller.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-internal"="yes" \
    --set controller.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-ssl-cert"="${ACM_ARN}" \
    --set controller.publishService.enabled=true \
    --set controller.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-backend-protocol"="http" \
    --set controller.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-ssl-ports"="https" \
    --set controller.service.targetPorts.https=http \
    --set controller.service.targetPorts.http=http \
    --set controller.nodeSelector."kops\.k8s\.io/instancegroup"="nodes" \
    --set defaultBackend.nodeSelector."kops\.k8s\.io/instancegroup"="nodes"

  # Public Nginx Ingress controller
  helm install stable/nginx-ingress --name nginx-ingress-public --namespace kube-system \
    --set rbac.create=true \
    --set controller.ingressClass=nginx-public \
    --set controller.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-ssl-cert"="${ACM_ARN}" \
    --set controller.publishService.enabled=true \
    --set controller.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-backend-protocol"="http" \
    --set controller.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-ssl-ports"="https" \
    --set controller.service.targetPorts.https=http \
    --set controller.service.targetPorts.http=http \
    --set controller.nodeSelector."kops\.k8s\.io/instancegroup"="nodes" \
    --set defaultBackend.nodeSelector."kops\.k8s\.io/instancegroup"="nodes"
fi
if [ ${INGRESS_CONTROLLER} == "alb" ]; then
  helm install incubator/aws-alb-ingress-controller \
    --name=alb-ingress-controller \
    --namespace=kube-system \
    -f alb-ingress-controller.yaml \
    --set clusterName=s${CLUSTER_NAME} \
    --set awsVpcID=${VPC_ID}
fi

# Cluster Autoscaling
helm install stable/cluster-autoscaler --name cluster-autoscaler --namespace kube-system -f cluster-autoscaler-${KUBE_ENV}.yaml

# Fluentd
git clone https://github.com/cxcloud/helm-fluentd-kinesis-firehose.git
helm install ./helm-fluentd-kinesis-firehose --name fluentd --namespace kube-system -f fluentd.yaml
