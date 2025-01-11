resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  chart      = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  namespace  = "kube-system"

  set {
    name  = "clusterName"
    value = module.eks.cluster_name
  }
  set {
    name  = "region"
    value = "us-east-1"
  }
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.alb_controller_role.arn
  }

  values = [
    <<-EOT
    clusterName: "${module.eks.cluster_name}"
    serviceAccount:
      create: true
      name: aws-load-balancer-controller
    EOT
  ]

  depends_on = [module.eks, aws_iam_role.alb_controller_role, aws_iam_role_policy_attachment.alb_controller_policy]
}

resource "aws_iam_policy" "alb_controller_policy" {
  name = "alb-controller-policy"
  description = "IAM policy for AWS Load Balancer Controller"
  policy = file("./policy/alb-controller-policy.json")
}

resource "aws_iam_role_policy_attachment" "alb_controller_policy" {
  role       = aws_iam_role.alb_controller_role.name
  policy_arn = aws_iam_policy.alb_controller_policy.arn
}

resource "aws_iam_role" "alb_controller_role" {
  name = "alb-controller-role"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Federated": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(data.aws_eks_cluster.current.identity[0].oidc[0].issuer, "https://", "")}"
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringEquals": {
            "${replace(data.aws_eks_cluster.current.identity[0].oidc[0].issuer, "https://", "")}:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })
}