path "database/creds/worker" {
  capabilities = ["read"]
}

path "kv/data/worker/*" {
  capabilities = ["read"]
}
