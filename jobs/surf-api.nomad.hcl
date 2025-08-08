job "surf-api" {
  datacenters = ["dc1"]
  type        = "service"

  update {
    stagger  = "30s"
    strategy = "canary"
  }

  group "surf-api" {
    network {
      port "http" {
        to = 8080
      }
    }

    service {
      name = "surf-api"
      port = "http"

      check {
        name     = "surf-api-health"
        type     = "http"
        path     = "/health"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "surf-api" {
      driver = "exec-fc"

      config {
        command = "/bin/surf-api"
      }
    }
  }
}
