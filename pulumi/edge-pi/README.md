# Edge Pi Pulumi Program

This Pulumi program SSHs into Raspberry Pi nodes, installs Nomad and Consul agents, and joins them to an existing federation.

## Prerequisites

- [Pulumi CLI](https://www.pulumi.com/docs/get-started/install/)
- Node.js and npm
- SSH access to each Pi node

## Install Dependencies

```bash
cd pulumi/edge-pi
npm install
```

## Configure

Set the target nodes and credentials using Pulumi config. The list of Pi hostnames or IPs is stored as a JSON array. The private key is stored as a secret.

```bash
pulumi config set edge-pi:nodes '["pi1.local","pi2.local"]' --path
pulumi config set edge-pi:username pi
pulumi config set edge-pi:consulServer consul.service.local
pulumi config set edge-pi:nomadServer nomad.service.local
pulumi config set --secret edge-pi:privateKey "$(cat ~/.ssh/id_rsa)"
```

## Deploy

```bash
pulumi up
```

The program will connect to each Pi, install the agents, enable the services, and join the specified federation.
