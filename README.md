# NomadWave – Carbon‑Aware Surf‑Conditions API on Firecracker + Nomad

## Table of Contents

1. [Project Overview](#project-overview)
2. [System Architecture](#system-architecture)
3. [Skill Mapping](#skill-mapping)
4. [Tech Stack](#tech-stack)
5. [Data Feeds](#data-feeds)
6. [Repository Layout](#repository-layout)
7. [Local Development Guide](#local-development-guide)
8. [Infrastructure‑as‑Code](#infrastructure-as-code)
9. [GitLab CI/CD Pipeline](#gitlab-ci/cd-pipeline)
10. [Nomad Job Specs & Progressive Delivery](#nomad-job-specs--progressive-delivery)
11. [Observability & GreenOps](#observability--greenops)
12. [Security & Secrets Management](#security--secrets-management)
13. [Chaos & Resilience Testing](#chaos--resilience-testing)
14. [Cost & Carbon Optimisation](#cost--carbon-optimisation)
15. [Demo Recording Script](#demo-recording-script)
16. [Troubleshooting & FAQ](#troubleshooting--faq)
17. [Stretch Goals](#stretch-goals)
18. [References](#references)

---

## Project Overview

**NomadWave** is a lightweight, zero‑Kubernetes DevOps showcase that delivers live surf‑condition forecasts while dynamically shifting compute between AWS Graviton instances and an on‑prem Raspberry Pi swarm based on *real‑time carbon intensity*.  The core API is packaged as an immutable OCI image, booted inside **Firecracker micro‑VMs** orchestrated by **HashiCorp Nomad**.  CI/CD runs on **GitLab**; each commit triggers a cost‑guarded, policy‑scanned pipeline that pushes a new Nomad job spec.  **Consul** mesh handles service discovery and canary traffic‑splitting; **VictoriaMetrics + Grafana** visualise latency and grams CO₂ per request; when carbon cost breaches a threshold, a custom Nomad autoscaler drains AWS nodes and migrates load to the green edge cluster — all filmed in a six‑minute video.

---

## System Architecture

```text
           Surf Buoy API      BOM Weather API
                  │                │
                  ▼                ▼
            +——————————+    +——————————+
            | ingest‑wave |    | ingest‑wx |   (Nomad jobs)
            +———┬———┬———+    +———┬———┬———+
                 │   │             │   │
                 ▼   │             ▼   │
            NATS JetStream  ◀──────┘   │  (queue events)
                 │                      │
                 ▼                      ▼
         +————————————+        +———————————+
         |  ClickHouse | ◀──────┤ carbon‑api │   (sidecar)
         +————————————+        +———————————+
                 ▲                      ▲
                 │  Consul Connect mTLS │
          ┌──────┴──────┐      ┌────────┴───────┐
          │ AWS Nomad   │      │ Edge Pi Nomad  │  (federated)
          │  (Sydney)   │◀────►│  (On‑Site)     │  (jobs drain/schedule)
          └─────────────┘      └────────────────┘
                       ▲  Route 53 weighted DNS  ▲
                       └──────────↔──────────────┘
```

*Green‑Shift event*: Carbon intensity feed from ElectricityMap causes autoscaler to set **AWS weight → 0; Edge weight → 100**.

---

## Skill Mapping

| DevOps Skill             | NomadWave Component                                                       |
| ------------------------ | ------------------------------------------------------------------------- |
| IaC (Terraform & Pulumi) | Terraform AWS VPC & EC2; Pulumi TS provisions on‑prem Nomad agents        |
| Immutable Images         | Packer builds Alpine‑based OCI images + Firecracker kernel/FS             |
| Non‑K8s Orchestration    | HashiCorp Nomad jobs with `exec-fc` Firecracker driver                    |
| Service Mesh             | Consul Connect sidecars, intentions (L7 allowlist)                        |
| GitOps / CI              | GitLab CI pipeline updates Nomad job spec repo; Terraform Cloud run tasks |
| Progressive Delivery     | Consul Service‑Splitter canary 5 %→50 %→100 % with SLO check              |
| Observability            | VictoriaMetrics, Grafana, Loki, OpenTelemetry traces                      |
| Secrets                  | Vault Agent sidecars inject DB creds; Boundary for debug sessions         |
| Chaos Testing            | Nomad‑FireDrill plugin kills allocations weekly                           |
| FinOps / GreenOps        | Carbon‑aware scheduler plugin, Infracost MR comments                      |

---

## Tech Stack

| Category       | Tools / Services                     |
| -------------- | ------------------------------------ |
| IaC            | Terraform 1.7, Pulumi v4             |
| Image Build    | Packer 1.10, Docker Buildx           |
| Orchestration  | Nomad 1.6, Consul 1.17, Firecracker  |
| CI/CD          | GitLab CI, Nomad job GitOps repo     |
| Observability  | VictoriaMetrics, Grafana 11, Loki    |
| Secrets & Auth | Vault 1.15, Boundary 0.14            |
| Cost‑Guardrail | Infracost, Carbon‐Aware Nomad Plugin |

---

## Data Feeds

| Feed           | Endpoint           | Frequency | Notes                |
| -------------- | ------------------ | --------- | -------------------- |
| NSW Wave Buoys | IMOS API (JSON)    | 10 min    | Wave height, period  |
| BOM Weather    | BOM Public API     | Hourly    | Wind, swell forecast |
| ElectricityMap | CO₂ intensity REST | 5 min     | Region carbon signal |

---

## Repository Layout

```
nomadwave/
├── packer/
│   └── surf-api.pkr.hcl          # Image & fc kernel build
├── terraform/
│   └── aws-core/                 # VPC, Nomad servers, IAM
├── pulumi/
│   └── edge-pi/                  # TS stack for Pi cluster
├── jobs/
│   ├── surf-api.nomad.hcl        # Service & canary splitter
│   └── ingest.nomad.hcl
├── ci/
│   └── .gitlab-ci.yml            # pipeline definition
├── services/
│   ├── surf-api/                 # Go HTTP service
│   └── ingest-wave/              # Go MQTT→NATS bridge
├── consul/                       # intentions, splitters, resolver
├── grafana_dashboards/
│   └── carbon_latency.json
├── chaos/
│   └── firedrill.yaml            # Nomad-FireDrill plan
└── docs/
    ├── architecture.png
    └── demo_script.md
```

---

## Local Development Guide

```bash
# 1. Build & test surf‑api
cd services/surf-api && go test ./...

# 2. Run dev Firecracker VM via nomad-pack
nomad dev &   # start local agent
nomad job run jobs/surf-api.nomad.hcl
curl localhost:8081/healthz

# 3. Visualise logs
nomad alloc logs -f <alloc-id>
```

Edge simulation (`docker compose up edge-sim`) publishes fake buoy data to local NATS.

---

## Infrastructure‑as‑Code

1. **Terraform** `aws-core` creates VPC, public/private subnets, Nomad & Consul server ASG (t4g.micro), Route 53 zone, IAM roles.
2. **Pulumi** `edge-pi` script SSHs to Pi nodes, installs Nomad agent, joins federation.

Run order:

```bash
cd terraform/aws-core && terraform apply
cd pulumi/edge-pi && pulumi up
```

Terraform Cloud run tasks enforce policy checks & Infracost diff.

---

## GitLab CI/CD Pipeline (simplified)

```yaml
stages: [test, scan, build, deploy]
variables:
  IMAGE: registry.gitlab.com/$CI_PROJECT_PATH/surf-api:$CI_COMMIT_SHORT_SHA

test:
  stage: test
  script: go test ./...

scan:
  stage: scan
  image: aquasec/trivy:latest
  script: trivy image --severity HIGH $IMAGE

build:
  stage: build
  script:
    - docker build -t $IMAGE services/surf-api
    - docker push $IMAGE

deploy:
  stage: deploy
  script:
    - sed -i "s|image \*=.*|image = \"$IMAGE\"|" jobs/surf-api.nomad.hcl
    - git commit -am "update image tag" && git push
```

Nomad job GitOps repo watch picks up commit; Consul splitter starts canary.

---

## Nomad Job Specs & Progressive Delivery

* **surf-api.nomad.hcl** sets `count = 2`, `update { stagger 30s strategy "canary"}`.
* Consul **service‑splitter** splits 5 % traffic to new job version; autopromote if latency <150 ms.
* **Consul Resolver** fails AWS subset when autoscaler drains nodes.

---

## Observability & GreenOps

* **VictoriaMetrics** scrape Nomad metrics gateway; carbon plugin emits `co2_per_request` gauge.
* Grafana dashboard combines RED + CO₂; alert fires when `co2_per_request > 1.0 g` for 5 min.
* Nomad **autoscaler plugin** listens and triggers `nomad node drain` on AWS pool.

---

## Security & Secrets Management

* Vault Agent sidecar pulls DB creds, renews every 4 h.
* Boundary session broker gives `kubectl`‑like exec into VMs without SSH keys.
* Consul intentions: only `surf-api` can query `clickhouse`, deny all else.

---

## Chaos & Resilience Testing

* **Nomad‑FireDrill** plan:

  ```hcl
  experiment "kill-pi-alloc" {
    target "alloc" {
      selector = "node.class == \"pi\""
      percent  = 50
    }
    action "kill" {}
  }
  ```
* Weekly cron triggers experiment; PagerDuty on allocation recovery >120 s.

---

## Cost & Carbon Optimisation

| Component                                                            | Optimisation                              | AUD/mo |
| -------------------------------------------------------------------- | ----------------------------------------- | ------ |
| AWS Graviton EC2                                                     | Spot c7g.medium, scale 0–3 via autoscaler | 6      |
| Pi Cluster                                                           | Solar‑powered, passive cooling            | 1      |
| S3 + ClickHouse                                                      | GP3 20 GB + tiered Glacier archive        | 3      |
| Monitoring                                                           | VictoriaMetrics single‑node, Grafana OSS  | 0      |
| Total (idle)                                                         |                                           | **10** |
| Carbon footprint ≈ **0.15 kg CO₂/day** (80 % running on solar edge). |                                           |        |

---

## Demo Recording Script

| Time | Scene              | Key Point                            |
| ---- | ------------------ | ------------------------------------ |
| 0:00 | Selfie intro       | Surf‑API + carbon‑aware routing      |
| 0:30 | GitLab MR          | cost diff & Trivy badge green        |
| 1:00 | Nomad UI           | job version v2 canary 5 %            |
| 1:45 | Grafana            | latency & CO₂ stable, autopromote    |
| 2:15 | Simulate CO₂ spike | curl carbon API override             |
| 2:45 | Autoscaler         | drains AWS nodes → edge              |
| 3:15 | FireDrill chaos    | kill Pi alloc; Nomad reschedules AWS |
| 4:00 | Boundary shell     | no SSH, short‑lived token            |
| 4:30 | Cost & CO₂ slide   | <\$10/mo, 80 % green energy          |
| 5:00 | Outro              | GitLab repo link & subscribe call    |

Record 1440p 60 fps; OBS profile `docs/obs/nomadwave.json`.

---

## Troubleshooting & FAQ

| Issue                       | Resolution                                                   |
| --------------------------- | ------------------------------------------------------------ |
| Nomad job stuck "pending"   | Check Firecracker kernel path & host CPU virtualization flag |
| Consul splitter not routing | Verify service‑defaults & L7 route prefix matches `/v1/*`    |
| Vault token expired         | Ensure Agent auto‑auth role bound to EC2 IAM role            |
| VictoriaMetrics high RAM    | Enable downsampling & remote write compression               |

---

## Stretch Goals

* **Cilium CNI** inside Nomad bridge for eBPF flow logs.
* **SPIFFE/SPIRE** workload IDs → Connect CA plug‑in.
* **Nomad Pack Templates** for one‑line job deploys.

---

## References

* HashiCorp Nomad Firecracker driver guide – 2025
* Consul Service Splitter docs – 2024
* VictoriaMetrics cluster setup – 2025
* ElectricityMap API – [https://www.electricitymaps.com/api](https://www.electricitymaps.com/api)

---

*Last updated: 4 Aug 2025*
