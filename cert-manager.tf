# resource "helm_release" "cert_manager" {
#   name       = "cert-manager"
#   namespace  = "cert-manager"
#   repository = "https://charts.jetstack.io"
#   chart      = "cert-manager"
#   version    = "v1.9.0"
#   create_namespace = true

#   values = [
#     <<-EOT
#     installCRDs: true
#     EOT
#   ]
# }

# resource "kubernetes_manifest" "letsencrypt_cluster_issuer" {
#   manifest = {
#     apiVersion = "cert-manager.io/v1"
#     kind       = "ClusterIssuer"
#     metadata = {
#       name = "letsencrypt-prod"
#     }
#     spec = {
#       acme = {
#         server = "https://acme-v02.api.letsencrypt.org/directory"
#         email  = "rafael.cavasani@hotmail.com"
#         privateKeySecretRef = {
#           name = "letsencrypt-prod-private-key"
#         }
#         solvers = [
#           {
#             http01 = {
#               ingress = {
#                 class = "nginx"
#               }
#             }
#           }
#         ]
#       }
#     }
#   }
#   depends_on = [ module.eks,helm_release.cert_manager ]
# }
