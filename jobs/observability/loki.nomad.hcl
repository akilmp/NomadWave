job "loki" {
  datacenters = ["dc1"]
  type        = "service"

  group "loki" {
    count = 1

    network {
      port "http" {
        to = 3100
      }
    }

    task "loki" {
      driver = "docker"

      config {
        image = "grafana/loki"
        args  = ["-config.file=/etc/loki/local-config.yaml"]
        ports = ["http"]
      }

      resources {
        cpu    = 500
        memory = 512
      }

      service {
        name = "loki"
        port = "http"
        tags = ["logs"]
      }
    }
  }
}
