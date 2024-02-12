resource "aws_security_group_rule" "eks" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = -1
  security_group_id        = module.eks.cluster_primary_security_group_id
  source_security_group_id = module.karpenter_node_sg.security_group_id
  description              = "Karpenter"
}
