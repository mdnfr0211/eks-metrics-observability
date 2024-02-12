module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "20.2.1"

  cluster_name           = module.eks.cluster_name
  irsa_oidc_provider_arn = module.eks.oidc_provider_arn

  create_iam_role = true

  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
}

module "karpenter_node_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  name        = format("%s-%s", "karpenter-node", "sg")
  description = "Managed by Terraform"

  vpc_id = var.vpc_id

  ingress_with_source_security_group_id = [
    {
      from_port                = 0
      to_port                  = 0
      protocol                 = -1
      description              = "EKS Cluster Security Group"
      source_security_group_id = module.eks.cluster_primary_security_group_id
    }
  ]

  ingress_with_cidr_blocks = []

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      description = "Egress - Allow all traffic"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

resource "aws_eks_pod_identity_association" "karpenter" {
  cluster_name    = module.eks.cluster_name
  namespace       = "karpenter"
  service_account = "karpenter"
  role_arn        = module.karpenter.iam_role_arn
}
