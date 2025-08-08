# Data Pipeline

The NomadWave data pipeline ingests raw surf and weather events, buffers them in NATS JetStream and persists curated observations in ClickHouse.

## Flow
1. **Producers** publish buoy and weather JSON to JetStream.
2. **Ingest workers** consume the stream and batch insert into ClickHouse.
3. **API** queries ClickHouse for recent conditions.

## Retention Policies
- **NATS JetStream**
  - Messages retained for up to **7 days** or **2 GB**, whichever comes first.
  - Backed by a host volume to survive client restarts.
- **ClickHouse**
  - `surf.observations` table uses a TTL to drop rows after **30 days**.
  - Older snapshots can be archived to object storage for long‑term analysis.
