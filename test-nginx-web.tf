provider "kubernetes" {
}

resource "kubernetes_deployment" "web_nginx" {
  metadata {
    name = "terraform-nginx"
    labels = {
      app         = "nginx"
      provisioner = "Terraform"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "nginx"
      }
    }
    template {
      metadata {
        labels = {
          app = "nginx"
        }
      }
      spec {
        container {
          image = "nginx:1.7.8"
          name  = "my-nginx"
          resources {
            limits {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "svc-nginx" {
  metadata {
    labels = {
      app         = "nginx"
      provisioner = "Terraform"
    }
    name = "nginx"
  }
  spec {
    selector = {
      app = "nginx"
    }
    port {
      port        = 80
      target_port = 80
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_ingress" "igr_nginx" {
    metadata {
      name = "web-nginx"
      annotations = {
        "kubernetes.io/ingress.class" = "nginx"
      }
      labels = {
        app = "nginx"
      }
    }

    spec {
      rule {
        host = "nginx-web.local"
        http {
          path {
            path = "/"
            backend {
              service_name = kubernetes_service.svc-nginx.metadata[0].name
              service_port = 80
            }
          }
        }
      }
    }
}
