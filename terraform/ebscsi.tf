module "ebs_csi_pod_identity" {
  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "~> 2.7"

  name = "ebs-csi"

  attach_aws_ebs_csi_policy = true

  associations = {
    ebs_csi = {
      cluster_name    = module.eks.cluster_name
      namespace       = "kube-system"
      service_account = "ebs-csi-controller-sa"
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}