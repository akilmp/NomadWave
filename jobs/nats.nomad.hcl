job "nats" {
  datacenters = ["dc1"]

  group "nats" {
    count = 1

    volume "nats-data" {
      type      = "host"
      read_only = false
      source    = "nats"
    }

    network {
      port "nats" {
        to = 4222
      }
      port "http" {
        to = 8222
      }
    }

    task "server" {
      driver = "docker"

      config {
        image = "nats:2.10-alpine"
        ports = ["nats", "http"]
        args  = ["-c", "${NOMAD_ALLOC_DIR}/local/nats.conf"]
      }

      template {
        destination = "local/nats.conf"
        data = <<EOT
port: 4222
http: 8222
jetstream {
  store_dir: /data/jetstream
  max_mem: 256MB
  max_file: 2GB
}
EOT
      }

      volume_mount {
        volume      = "nats-data"
        destination = "/data"
      }

      resources {
        cpu    = 200
        memory = 128
      }

      service {
        name = "nats"
        port = "nats"
      }
    }
  }
}
