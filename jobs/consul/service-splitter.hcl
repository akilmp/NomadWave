# Consul service-splitter for surf-api progressive rollouts.
# Start with 5% of traffic directed to the canary subset and
# update the weights to 50% and 100% as the deployment proceeds.

Kind = "service-splitter"
Name = "surf-api"

# Stage 1: 5% canary
Splits = [
  { Weight = 95, Service = "surf-api", ServiceSubset = "v1" },
  { Weight = 5,  Service = "surf-api", ServiceSubset = "v2" }
]

# Stage 2: adjust weights to 50/50
# Splits = [
#   { Weight = 50, Service = "surf-api", ServiceSubset = "v1" },
#   { Weight = 50, Service = "surf-api", ServiceSubset = "v2" }
# ]

# Stage 3: 100% to v2
# Splits = [
#   { Weight = 100, Service = "surf-api", ServiceSubset = "v2" }
# ]
