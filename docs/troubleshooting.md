# Troubleshooting NomadWave

Common fixes for Nomad, Consul, and Vault.

## Nomad
- **Job stuck in `pending`**: verify Firecracker kernel path and that the host supports hardware virtualization.
- **Autoscaler not draining nodes**: check plugin ACL token and connectivity to the Nomad servers.
- **Allocation fails to start**: ensure sufficient CPU/RAM and inspect `nomad alloc logs <id>` for errors.

## Consul
- **Service not discoverable**: confirm registration with `consul catalog services` and that agents are joined.
- **Splitter not routing traffic**: ensure `service-defaults` and `service-splitter` prefixes match `/v1/*`.
- **mTLS handshake failures**: verify certificates issued by Consul Connect and that system clocks are synced.

## Vault
- **Token expired**: configure Vault Agent auto-auth and check renewal status with `vault token lookup`.
- **Secret not injected**: validate template paths and run the agent with `-log-level=debug` for diagnostics.
- **Connection refused**: confirm `VAULT_ADDR` is reachable and firewall rules allow access.
