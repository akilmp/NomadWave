# syntax=docker/dockerfile:1
FROM golang:1.22 AS build
WORKDIR /src
COPY go.mod go.sum .
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o surf-api

FROM gcr.io/distroless/base-debian12
COPY --from=build /src/surf-api /surf-api
EXPOSE 8080
ENTRYPOINT ["/surf-api"]
