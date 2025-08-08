package main

import (
    "log"
    "net/http"

    "github.com/NomadWave/surf-api"
)

func main() {
    srv := surfapi.NewServer(surfapi.StaticReporter{})
    log.Fatal(http.ListenAndServe(":8080", srv))
}

