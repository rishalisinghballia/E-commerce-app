############################################################
# Argo CD - Helm Release
############################################################

resource "helm_release" "argocd" {

  name      = "argocd"
  namespace = "argocd"

  create_namespace = true

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"

  # Pin the chart for reproducibility
  version = "10.8.4"

  wait    = true
  timeout = 900

  values = [
    yamlencode({

      ######################################################
      # Global
      ######################################################

      global = {
        domain = "argocd.rishindra.shop"
      }

      ######################################################
      # Argo CD Application Controller
      ######################################################

      controller = {
        replicas = 1

        resources = {
          requests = {
            cpu    = "250m"
            memory = "512Mi"
          }

          limits = {
            cpu    = "1000m"
            memory = "1Gi"
          }
        }
      }

      ######################################################
      # Argo CD Server
      ######################################################

      server = {
        replicas = 2

        resources = {
          requests = {
            cpu    = "250m"
            memory = "256Mi"
          }

          limits = {
            cpu    = "1000m"
            memory = "512Mi"
          }
        }

        ingress = {
          enabled = true

          controller = "aws"

          ingressClassName = "alb"

          annotations = {

            "alb.ingress.kubernetes.io/scheme" = "internet-facing"

            "alb.ingress.kubernetes.io/target-type" = "ip"

            "alb.ingress.kubernetes.io/backend-protocol" = "HTTP"

            "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTP\":80}, {\"HTTPS\":443}]"

            "alb.ingress.kubernetes.io/ssl-redirect" = "443"

            "alb.ingress.kubernetes.io/certificate-arn" = "arn:aws:acm:us-east-1:413027378621:certificate/d5f34c4b-f6bb-4933-8d30-c0b1ed137524"

            "alb.ingress.kubernetes.io/group.name" = "argocd-app-lb"
          }

          aws = {
            serviceType = "ClusterIP"

            backendProtocolVersion = "GRPC"
          }
        }
      }

      ######################################################
      # Repository Server
      ######################################################

      repoServer = {
        replicas = 2

        resources = {
          requests = {
            cpu    = "250m"
            memory = "512Mi"
          }

          limits = {
            cpu    = "1000m"
            memory = "1Gi"
          }
        }
      }

      ######################################################
      # ApplicationSet Controller
      ######################################################

      applicationSet = {
        replicas = 2

        resources = {
          requests = {
            cpu    = "100m"
            memory = "128Mi"
          }

          limits = {
            cpu    = "500m"
            memory = "512Mi"
          }
        }
      }

      ######################################################
      # Redis HA
      ######################################################

      redis-ha = {
        enabled = true

        auth = true

        hardAntiAffinity = true

        persistentVolume = {
          enabled      = true
          storageClass = "gp2"
          size         = "10Gi"
        }

        topologySpreadConstraints = {
          enabled = true

          maxSkew = 1

          topologyKey = "topology.kubernetes.io/zone"

          whenUnsatisfiable = "ScheduleAnyway"
        }
      }

      ######################################################
      # TLS termination
      ######################################################

      configs = {
        params = {
          "server.insecure" = "true"
        }
      }

    })
  ]

  depends_on = [
    module.eks,
    helm_release.aws_load_balancer_controller
  ]
}