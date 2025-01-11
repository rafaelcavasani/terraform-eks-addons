resource "helm_release" "external_dns" {
  name       = "external-dns"
  chart      = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns"
  namespace  = "kube-system"

  set {
    name  = "provider"
    value = "aws"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.external_dns_role.arn
  }

  set {
    name  = "serviceAccount.name"
    value = "external-dns"
  }

  set {
    name  = "aws.accessKeyId"
    value = var.aws_access_key_id
  }

  set {
    name  = "aws.secretAccessKey"
    value = var.aws_secret_access_key
  }

  set {
    name  = "aws.region"
    value = var.region
  }

  set_list {
    name  = "domainFilters"
    value = ["cavas.dev.br"]
  }

  set {
    name  = "rfc2136.enabled"
    value = "false"
  }

  depends_on = [module.eks, aws_iam_role.external_dns_role]
}

resource "aws_iam_policy" "external_dns_policy" {
  name        = "external-dns-policy"
  description = "Permissões para o external-dns acessar e gerenciar registros DNS no Route 53"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets",
          "route53:ChangeResourceRecordSets",
          "route53:ListTagsForResource"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        "Effect" = "Allow",
        "Action" = [
          "route53:ChangeResourceRecordSets"
        ],
        "Resource" = [
          "arn:aws:route53:::hostedzone/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "external_dns_role" {
  name               = "external-dns-role"
  assume_role_policy = <<EOF
    {
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
              "${replace(data.aws_eks_cluster.current.identity[0].oidc[0].issuer, "https://", "")}:sub": "system:serviceaccount:kube-system:external-dns"
            }
          }
        }
      ]
    }
      EOF
}

resource "aws_iam_role_policy_attachment" "external_dns_policy_attachment" {
  policy_arn = aws_iam_policy.external_dns_policy.arn
  role       = aws_iam_role.external_dns_role.name
  depends_on = [ aws_iam_policy.external_dns_policy, aws_iam_role.external_dns_role ]
}
