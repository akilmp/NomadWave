job "clickhouse" {
  datacenters = ["dc1"]

  group "clickhouse" {
    count = 1

    volume "ch-data" {
      type      = "host"
      read_only = false
      source    = "clickhouse"
    }

    network {
      port "tcp" {
        to = 9000
      }
      port "http" {
        to = 8123
      }
    }

    task "server" {
      driver = "docker"

      config {
        image   = "clickhouse/clickhouse-server:23-alpine"
        ports   = ["tcp", "http"]
        volumes = ["local:/docker-entrypoint-initdb.d"]
      }

      template {
        destination = "local/schema.sql"
        data = <<EOT
CREATE DATABASE IF NOT EXISTS surf;

CREATE TABLE IF NOT EXISTS surf.observations (
  station_id String,
  ts DateTime,
  wave_height Float32,
  wave_period Float32,
  wind_speed Float32,
  wind_direction UInt16
) ENGINE = MergeTree()
ORDER BY (station_id, ts)
TTL ts + INTERVAL 30 DAY;
EOT
      }

      volume_mount {
        volume      = "ch-data"
        destination = "/var/lib/clickhouse"
      }

      resources {
        cpu    = 500
        memory = 512
      }

      service {
        name = "clickhouse"
        port = "tcp"
        tags = ["db"]
      }
    }
  }
}
