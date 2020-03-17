data "kubernetes_storage_class" "nfs-client" {
  metadata {
      name = "nfs-client"
  }
}

resource "kubernetes_persistent_volume_claim" "test-claim" {
  metadata {
    name = "test-claim"
  }
  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "1Mi"
      }
    }
    storage_class_name = data.kubernetes_storage_class.nfs-client.metadata[0].name
  }
}

resource "kubernetes_pod" "test" {
  metadata {
      name = "test-pod"
  }
  spec {
      container {
          image = "gcr.io/google_containers/busybox:1.24"
          name = "test-pod"
          command = ["/bin/sh"]
          args = ["-c", "touch /mnt/SUCCESS && exit 0 || exit 1"]
          volume_mount {
              name = "nfs-pvc"
              mount_path = "/mnt"
          }
      }
      
      restart_policy = "Never"
      volume {
          name = "nfs-pvc"
          persistent_volume_claim {
              claim_name = kubernetes_persistent_volume_claim.test-claim.metadata[0].name
          }
      }
  }
}
