resource "helm_release" "nginx_ingress" {
  name       = "ingress-nginx"
  namespace  = "nginx-ingress-controller"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.10.1"

  create_namespace = true

  values = [file("./values/ngnix-ingress-controller-values.yaml")]
}