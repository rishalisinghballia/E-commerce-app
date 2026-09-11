module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "my-demo-terraform-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  map_public_ip_on_launch = true  # this is required for public subnets to assign public IPs to instances launched in them
  enable_nat_gateway      = false # this will disable the creation of NAT Gateways and associated Elastic IPs, which will save costs. However, this means that instances in private subnets will not have internet access unless you set up a NAT instance or some other mechanism.
  enable_vpn_gateway      = false # this will disable the creation of a VPN Gateway, which is not needed for this demo setup.

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1" # this is required for public subnets to be used by ELB
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}