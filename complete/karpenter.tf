resource "helm_release" "karpenter" {
  namespace        = "karpenter"
  create_namespace = true

  name                = "karpenter"
  repository          = "oci://public.ecr.aws/karpenter"
  repository_username = data.aws_ecrpublic_authorization_token.token.user_name
  repository_password = data.aws_ecrpublic_authorization_token.token.password
  chart               = "karpenter"
  version             = "v0.33.0"

  set {
    name  = "settings.clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "settings.interruptionQueueName"
    value = module.eks.karpenter_queue_name
  }
}

resource "kubectl_manifest" "karpenter_nodepool" {
  yaml_body = <<-YAML
    apiVersion: karpenter.sh/v1beta1
    kind: NodePool
    metadata:
      name: monitoring
    spec:
      limits:
        cpu: 1000
      template:
        metadata:
          labels:
            app: monitoring
            provisioner: karpenter
        spec:
          consolidation:
            enabled: true
          nodeClassRef:
            apiVersion: karpenter.k8s.aws/v1beta1
            kind: EC2NodeClass
            name: default
          requirements:
            - key: karpenter.sh/capacity-type
              operator: In
              values:
                - spot
            - key: node.kubernetes.io/instance-type
              operator: In
              values:
                - t3.large
                - t3a.large
                - t3.xlarge
                - t3a.xlarge
          taints:
            - key: app
              value: monitoring
              effect: NoSchedule
  YAML

  depends_on = [
    helm_release.karpenter
  ]
}

resource "kubectl_manifest" "karpenter_nodeclass" {
  yaml_body = <<-YAML
    apiVersion: karpenter.k8s.aws/v1beta1
    kind: EC2NodeClass
    metadata:
      name: default
    spec:
      amiFamily: Bottlerocket
      role: ${module.eks.karpenter_role_name}
      subnetSelectorTerms:
      - tags:
          karpenter.sh/discovery: ${module.eks.cluster_name}
      securityGroupSelectorTerms:
      - id: ${module.eks.karpenter_security_group_id}
  YAML

  depends_on = [
    helm_release.karpenter
  ]
}
