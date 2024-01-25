resource "helm_release" "nginx" {
  name       = "nginx"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "nginx"

  values = [
    file("${path.module}/nginx-values.yaml")
  ]
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "3.35.4"
  values           = [
    file("${path.module}/argocd.yaml")
    ]
}

resource "helm_release" "argo_rollouts" {
    
    name                = "argo-rollouts"
    chart               = "argo-rollouts"
    repository          = "https://argoproj.github.io/argo-helm"
    namespace           = "argo-rollouts"
    create_namespace    = true

    set {
            name = "dashboard.enabled"
            value = false
        }
}
# helm install argocd -n argocd -f values/argocd.yaml


# resource "helm_release" "istio-base" {
#   chart            = "base"
#   namespace        = var.k8s_namespace
#   create_namespace = var.create_namespace
#   name             = "istio-base"
#   version          = var.helm_chart_version
#   repository       = var.helm_repo_url == "./helm" ? "${path.module}/helm" : var.helm_repo_url
#   force_update     = var.force_update
#   recreate_pods    = var.recreate_pods

#   values = [
#     yamlencode(var.istio_base_settings)
#   ]
# }

# resource "helm_release" "istiod" {
#   depends_on       = [helm_release.istio-base]
#   chart            = "istiod"
#   namespace        = var.k8s_namespace
#   create_namespace = var.create_namespace
#   name             = "istiod"
#   version          = var.helm_chart_version
#   repository       = var.helm_repo_url == "./helm" ? "${path.module}/helm" : var.helm_repo_url
#   force_update     = var.force_update
#   recreate_pods    = var.recreate_pods

#   values = [
#     yamlencode(
#       {
#         global = {
#           network = var.istiod_global_network
#           meshID  = var.istiod_global_meshID
#           multiCluster = {
#             clusterName = var.cluster_name
#           }
#         }
#         pilot = {
#           env = {
#             PILOT_SKIP_VALIDATE_TRUST_DOMAIN = var.istiod_pilot_env_PilotSkipValidateTrustDomain
#           }
#         }
#         meshConfig = {
#           rootNamespace  = var.istiod_meshConfig_rootNamespace
#           trustDomain    = var.cluster_name
#           accessLogFile  = var.istiod_meshConfig_accessLogFile
#           enableAutoMtls = var.istiod_meshConfig_enableAutoMtls
#           defaultConfig = {
#             envoyMetricsService = {
#               address = var.istiod_meshConfig_defaultConfig_envoyMetricsService_address
#             }
#             envoyAccessLogService = {
#               address = var.istiod_meshConfig_defaultConfig_envoyAccessLogService_address
#             }
#             proxyMetadata = {
#               ISTIO_META_DNS_CAPTURE       = var.istiod_meshConfig_defaultConfig_proxyMetadata_IstioMetaDNSCapture
#               ISTIO_META_DNS_AUTO_ALLOCATE = var.istiod_meshConfig_defaultConfig_proxyMetadata_IstioMetaDNSAutoAllocate
#               GLOO_MESH_CLUSTER_NAME       = var.cluster_name
#             }
#           }
#         }
#       }
#     )
#   ]
# }

# # resource "kubernetes_secret" "istio-ca" {
# #   count      = var.enable_aws_secret_manager_based_certs ? 1 : 0
# #   depends_on = [helm_release.istio-base]

# #   metadata {
# #     name      = "cacerts"
# #     namespace = "istio-system"
# #   }

# #   # data = {
# #   #   "ca-cert.pem"    = data.aws_secretsmanager_secret_version.ca_cert[count.index].secret_string
# #   #   "cert-chain.pem" = data.aws_secretsmanager_secret_version.ca_cert[count.index].secret_string
# #   #   "ca-key.pem"     = data.aws_secretsmanager_secret_version.ca_private_key[count.index].secret_string
# #   #   "root-cert.pem"  = data.aws_secretsmanager_secret_version.ca_cert_chain[count.index].secret_string
# #   # }
# # }