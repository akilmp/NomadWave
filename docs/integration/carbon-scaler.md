# Carbon Scaler Plugin

The carbon scaler plugin monitors a carbon-intensity API and reacts by
updating Nomad nodes. When the reported CO₂ intensity rises above a
configured threshold the plugin drains the target node. Otherwise it sets the
node's weight to a desired value to attract workloads.

## Usage

```bash
carbon-scaler -node-id="edge-1" -api-url="http://localhost:8080/intensity" \
  -threshold=400 -weight=50
```

The example above drains `edge-1` when the intensity exceeds `400` gCO₂/kWh.
When intensity is lower the node weight is set to `50` via the Nomad CLI.

## Testing

Unit tests can be executed with:

```bash
go test ./plugins/carbon-scaler
```

The tests mock both the carbon-intensity service and the Nomad command runner
so they do not require a running Nomad cluster.
