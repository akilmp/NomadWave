# Observability

NomadWave's observability stack is composed of VictoriaMetrics for metrics storage, Grafana for dashboards, and Loki for log aggregation.

## Scrape Targets

VictoriaMetrics scrapes the following targets:

- Nomad metrics gateway on `:4646`
- Application metrics exposed by `surf-api`
- Carbon plugin metrics including `co2_per_request`
- Loki and Grafana internal `/metrics` endpoints

## Alerting Rules

The cluster defines two primary alerting rules:

1. **High CO₂ per Request** – triggers when `co2_per_request > 1.0` for 5 minutes.
2. **Request Latency** – triggers when `http_request_duration_ms` average exceeds 150 ms for 5 minutes.

Alerts are routed to the Nomad autoscaler which can drain high‑carbon nodes.
