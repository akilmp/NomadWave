path "database/creds/web" {
  capabilities = ["read"]
}

path "kv/data/web/*" {
  capabilities = ["read"]
}
