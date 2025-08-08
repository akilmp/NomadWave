job "db-example" {
  datacenters = ["dc1"]

  group "app" {
    task "api" {
      driver = "docker"
      config {
        image = "myorg/api:latest"
      }

      volume_mount {
        volume      = "secrets"
        destination = "/secrets"
      }

      env {
        DB_CREDS_FILE = "/secrets/db-creds.env"
      }
    }

    task "vault-agent" {
      driver = "docker"
      config {
        image   = "hashicorp/vault:1.13"
        command = "agent"
        args    = ["-config=/local/agent.hcl"]
      }

      volume_mount {
        volume      = "secrets"
        destination = "/secrets"
      }

      template {
        destination = "local/agent.hcl"
        data = <<EOT
auto_auth {
  method "approle" {
    config = {
      role_id_file_path   = "/secrets/role_id"
      secret_id_file_path = "/secrets/secret_id"
    }
  }
  sink "file" {
    config = {
      path = "/secrets/token"
    }
  }
}

template {
  contents = <<EOH
{{ with secret "database/creds/app" }}
DB_USERNAME={{ .Data.username }}
DB_PASSWORD={{ .Data.password }}
{{ end }}
EOH
  destination = "/secrets/db-creds.env"
}
EOT
      }
    }

    volume "secrets" {
      type      = "tmpfs"
      read_only = false
    }
  }
}
