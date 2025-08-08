# syntax=docker/dockerfile:1
FROM golang:1.22-alpine AS build
WORKDIR /src
COPY . .
RUN go build -o ingest-wx ./services/ingest-wx

FROM alpine:3.18
WORKDIR /app
COPY --from=build /src/ingest-wx .
ENV NATS_URL="" BOM_TOKEN="" BOM_API_URL=""
CMD ["./ingest-wx"]
