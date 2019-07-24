// IAM Role with policies
resource "aws_iam_instance_profile" "kops_nodes" {
  name = "kops-nodes"
  role = aws_iam_role.kops_nodes.name
}

resource "aws_iam_role" "kops_nodes" {
  name               = "kops-nodes"
  path               = "/"
  assume_role_policy = file("${path.module}/ec2-assume-role.json")
}

resource "aws_iam_policy" "alb_ingress_controller" {
  name        = "alb-ingress-controller"
  path        = "/"
  description = "ALB Ingress Controller"
  policy      = file("${path.module}/alb-ingress.json")
}

resource "aws_iam_policy" "cluster_autoscaler" {
  name        = "cluster-autoscaler"
  path        = "/"
  description = "Kubernetes cluster autoscaler"
  policy      = file("${path.module}/cluster-autoscaler.json")
}

resource "aws_iam_role_policy_attachment" "attach_ingress_controller" {
  role       = aws_iam_role.kops_nodes.name
  policy_arn = aws_iam_policy.alb_ingress_controller.arn
}

resource "aws_iam_role_policy_attachment" "cluster_autoscaler" {
  role       = aws_iam_role.kops_nodes.name
  policy_arn = aws_iam_policy.cluster_autoscaler.arn
}

resource "aws_iam_role_policy_attachment" "kinesis_firehose_full_access" {
  role       = aws_iam_role.kops_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonKinesisFirehoseFullAccess"
}

resource "aws_iam_role_policy_attachment" "ECS_registry_full_access" {
  role       = aws_iam_role.kops_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

resource "aws_iam_role_policy_attachment" "certificate_manager_read_only" {
  role       = aws_iam_role.kops_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCertificateManagerReadOnly"
}
