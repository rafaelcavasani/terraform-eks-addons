# addons.tf
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    token                  = data.aws_eks_cluster_auth.auth.token
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  }
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name
  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "auth" {
  name = module.eks.cluster_name
  depends_on = [module.eks]
}