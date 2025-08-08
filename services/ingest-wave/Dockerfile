# syntax=docker/dockerfile:1
FROM golang:1.22-alpine AS build
WORKDIR /src
COPY . .
RUN go build -o ingest-wave ./services/ingest-wave

FROM alpine:3.18
WORKDIR /app
COPY --from=build /src/ingest-wave .
ENV NATS_URL="" IMOS_TOKEN="" IMOS_API_URL=""
CMD ["./ingest-wave"]
