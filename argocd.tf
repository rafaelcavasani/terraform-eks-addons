resource "helm_release" "argocd" {
  name             = "argo-cd"
  chart            = "argo-cd"
  repository       = "https://argoproj.github.io/argo-helm"
  namespace        = "argocd"
  create_namespace = true
  version          = "3.35.4"

  values = [file("./values/argocd-values.yaml")]

  set {
    name = "server.service.annotations.external-dns\\.alpha\\.kubernetes\\.io/hostname"
    value = "argocd.cavas.dev.br"
  }

  depends_on = [module.eks]
}

# resource "helm_release" "argo_rollouts" {
#   name       = "argo-rollouts"
#   chart      = "argo-rollouts"
#   repository = "https://argoproj.github.io/argo-helm"
#   namespace  = "argo-rollouts"

#   values = ["./values/argo-rollouts-values.yaml"]

#   depends_on = [module.eks]
# }

# resource "helm_release" "argo_workflows" {
#   name       = "argo-workflows"
#   chart      = "argo-workflows"
#   repository = "https://argoproj.github.io/argo-helm"
#   namespace  = "argo-workflows"

#   values = ["./values/argo-workflows-values.yaml"]

#   depends_on = [module.eks]
# }
