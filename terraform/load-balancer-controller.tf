############################################################
# AWS Load Balancer Controller - EKS Pod Identity
############################################################

module "aws_load_balancer_controller_pod_identity" {
  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "2.8.2"

  name = "aws-load-balancer-controller"

  # Create and attach the AWS Load Balancer Controller IAM policy
  attach_aws_lb_controller_policy = true

  # Associate IAM role with Kubernetes ServiceAccount
  associations = {
    aws_load_balancer_controller = {
      cluster_name    = module.eks.cluster_name
      namespace       = "kube-system"
      service_account = "aws-load-balancer-controller"
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

############################################################
# AWS Load Balancer Controller - Helm
############################################################

resource "helm_release" "aws_load_balancer_controller" {
  name      = "aws-load-balancer-controller"
  namespace = "kube-system"

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"

  # AWS Load Balancer Controller Helm chart
  version = "1.14.0"

  wait    = true
  timeout = 600

  values = [
    yamlencode({
      clusterName = module.eks.cluster_name
      region      = "us-east-1"
      vpcId       = module.vpc.vpc_id

      replicaCount = 2

      serviceAccount = {
        create = true
        name   = "aws-load-balancer-controller"
      }
    })
  ]

  depends_on = [
    module.eks,
    module.aws_load_balancer_controller_pod_identity
  ]
}