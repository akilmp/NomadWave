# Consul Service Mesh

## mTLS Setup

Consul's Connect service mesh secures service-to-service communication with mutual TLS (mTLS).

1. Enable Connect on every agent:
   ```hcl
   connect {
     enabled = true
   }
   ```
2. Bootstrap the built-in certificate authority:
   ```bash
   consul connect ca bootstrap
   ```
   The command creates a root certificate and private key in the server's data directory.
3. Distribute the CA configuration to all agents. Each agent automatically requests and rotates leaf certificates for its services.
4. Register services with Connect sidecars or transparent proxies so that all traffic is encrypted.

## Certificate Rotation

Consul rotates leaf certificates automatically before they expire. Rotate the root CA or force leaf rotation when required:

- Rotate the root certificate:
  ```bash
  consul connect ca rotate
  ```
  Consul generates a new root certificate and creates a cross-signed intermediate so existing certificates remain valid during the transition.
- Force leaf certificate rotation:
  ```bash
  consul connect ca leaf rotate
  ```
  Use a short `leaf_cert_ttl` in the agent configuration (e.g., `72h`) to ensure regular rotation.

After a root rotation completes and all leaf certificates are renewed, remove the old root certificate from the system.
