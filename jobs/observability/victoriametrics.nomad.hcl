job "victoriametrics" {
  datacenters = ["dc1"]
  type        = "service"

  group "vm" {
    count = 1

    network {
      port "http" {
        to = 8428
      }
    }

    task "victoriametrics" {
      driver = "docker"

      config {
        image = "victoriametrics/victoria-metrics"
        ports = ["http"]
        args  = ["--selfScrapeInterval=30s"]
      }

      resources {
        cpu    = 500
        memory = 512
      }

      service {
        name = "victoriametrics"
        port = "http"
        tags = ["metrics"]
      }
    }
  }
}
