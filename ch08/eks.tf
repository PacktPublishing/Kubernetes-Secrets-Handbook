module "ksm_eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.3"

  cluster_name    = var.cluster_name
  cluster_version = var.eks_version

  vpc_id                         = module.ksm_vpc.vpc_id
  subnet_ids                     = module.ksm_vpc.private_subnets
  cluster_endpoint_public_access = true

#   create_kms_key = false
#   cluster_encryption_config = {
#     resources = ["secrets"]
#     provider_key_arn = aws_kms_key.ksm_kms_key.arn
#   }


  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"

  }

  create_cloudwatch_log_group = true

  eks_managed_node_groups = {
    one = {
      name = "node-group-1"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 3
      desired_size = 1
    }

  }
}