# This module creates and Pod Identity association for the EBS CSI controller. It is required to allow the EBS CSI controller to create and manage EBS volumes in your AWS account.

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