job "ingest" {
  datacenters = ["dc1"]
  type        = "service"

  update {
    stagger  = "30s"
    strategy = "canary"
  }

  group "ingest" {
    network {
      port "http" {
        to = 9000
      }
    }

    service {
      name = "ingest"
      port = "http"

      check {
        name     = "ingest-health"
        type     = "http"
        path     = "/health"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "ingest" {
      driver = "exec-fc"

      config {
        command = "/bin/ingest"
      }
    }
  }
}
