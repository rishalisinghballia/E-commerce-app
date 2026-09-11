module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = "my-demo-terraform-eks"
  kubernetes_version = "1.33"

  addons = {
    coredns = {
      enabled     = true
      most_recent = true
    }

    eks-pod-identity-agent = {
      enabled        = true
      before_compute = true
    }

    kube-proxy = {
      enabled     = true
      most_recent = true
    }

    vpc-cni = {
      enabled               = true
      before_compute        = true
      most_recent           = true
      attach_vpc_cni_policy = true
    }

    aws-ebs-csi-driver = {
      enabled     = true
      most_recent = true
    }

    metrics-server = {
      enabled = true
    }
  }

  endpoint_public_access = true

  enable_cluster_creator_admin_permissions = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets

  eks_managed_node_groups = {
    eks-managed-group = {
      instance_types = ["c7i-flex.large"]

      min_size     = 3
      max_size     = 4
      desired_size = 3
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}