# Security

## Boundary Ephemeral Exec Access

Use [HashiCorp Boundary](https://www.boundaryproject.io/) to provide just-in-time shell
access to Nomad workloads.  Boundary brokers temporary credentials and terminates
the session when finished, limiting exposure of long-lived SSH keys.

### Example Target Configuration

```hcl
target "nomad-shell" {
  type              = "ssh"
  description       = "Ephemeral shell for Nomad allocations"
  scope_id          = "<project-scope-id>"
  default_port      = 22
  worker_filter     = "\"nomad\" in \"${boundary.worker.tags}\""
  session_max_seconds = 600
}
```

An operator can then open a session:

```bash
boundary connect ssh -target-id <target-id> -- -l ubuntu
```

Boundary issues an ephemeral credential and revokes it automatically when the
session ends.
