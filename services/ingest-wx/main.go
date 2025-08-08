package main

import (
    "context"
    "encoding/json"
    "log"
    "net/http"
    "os"
    "time"

    "github.com/nats-io/nats.go"
)

// BOMWeather represents minimal data from BOM API.
type BOMWeather struct {
    Station    string  `json:"station"`
    Temperature float64 `json:"temperature"`
}

func fetchBOM(ctx context.Context, client *http.Client, url, token string) (BOMWeather, error) {
    req, err := http.NewRequestWithContext(ctx, http.MethodGet, url, nil)
    if err != nil {
        return BOMWeather{}, err
    }
    if token != "" {
        req.Header.Set("Authorization", "Bearer "+token)
    }
    resp, err := client.Do(req)
    if err != nil {
        return BOMWeather{}, err
    }
    defer resp.Body.Close()
    var data BOMWeather
    if err := json.NewDecoder(resp.Body).Decode(&data); err != nil {
        return BOMWeather{}, err
    }
    return data, nil
}

func publishWeather(js nats.JetStreamContext, subject string, data BOMWeather) error {
    b, err := json.Marshal(data)
    if err != nil {
        return err
    }
    _, err = js.Publish(subject, b)
    return err
}

func main() {
    natsURL := os.Getenv("NATS_URL")
    token := os.Getenv("BOM_TOKEN")
    apiURL := os.Getenv("BOM_API_URL")
    if apiURL == "" {
        apiURL = "https://example.com/bom" // placeholder
    }

    nc, err := nats.Connect(natsURL)
    if err != nil {
        log.Fatal(err)
    }
    defer nc.Drain()

    js, err := nc.JetStream()
    if err != nil {
        log.Fatal(err)
    }

    client := &http.Client{Timeout: 10 * time.Second}
    ticker := time.NewTicker(5 * time.Minute)
    for {
        ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
        data, err := fetchBOM(ctx, client, apiURL, token)
        cancel()
        if err != nil {
            log.Printf("fetch error: %v", err)
        } else if err := publishWeather(js, "weather.data", data); err != nil {
            log.Printf("publish error: %v", err)
        }
        <-ticker.C
    }
}

