data "aws_caller_identity" "current" {}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.2.1"

  cluster_name                   = var.eks_name
  cluster_version                = var.eks_version
  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent    = true
      before_compute = true
    }
    eks-pod-identity-agent = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }

  vpc_id                   = var.vpc_id
  subnet_ids               = var.subnet_ids
  control_plane_subnet_ids = var.control_plane_subnet_ids

  create_cluster_security_group = true
  create_node_security_group    = false

  cluster_security_group_additional_rules = {}

  eks_managed_node_group_defaults = {
    use_custom_launch_template = false

    ami_type       = "BOTTLEROCKET_x86_64"
    platform       = "bottlerocket"
    instance_types = ["t3.medium", "t3a.medium"]
  }

  eks_managed_node_groups = {
    default = {
      use_custom_launch_template = false

      min_size       = 1
      max_size       = 2
      desired_size   = 2
      instance_types = ["t3.medium"]
      disk_size      = 20
      remote_access  = {}

      iam_role_additional_policies = {
        EC2FullAccess = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
      }
    }
  }

  authentication_mode = "API_AND_CONFIG_MAP"
  access_entries = {
    1 = {
      kubernetes_groups = []
      principal_arn     = data.aws_caller_identity.current.arn
      policy_associations = {
        1 = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  tags = var.tags
}
