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

// IMOSWave represents a minimal subset of data from IMOS API.
type IMOSWave struct {
    Station string  `json:"station"`
    Height  float64 `json:"height"`
}

func fetchIMOS(ctx context.Context, client *http.Client, url, token string) (IMOSWave, error) {
    req, err := http.NewRequestWithContext(ctx, http.MethodGet, url, nil)
    if err != nil {
        return IMOSWave{}, err
    }
    if token != "" {
        req.Header.Set("Authorization", "Bearer "+token)
    }
    resp, err := client.Do(req)
    if err != nil {
        return IMOSWave{}, err
    }
    defer resp.Body.Close()
    var data IMOSWave
    if err := json.NewDecoder(resp.Body).Decode(&data); err != nil {
        return IMOSWave{}, err
    }
    return data, nil
}

func publishWave(js nats.JetStreamContext, subject string, data IMOSWave) error {
    b, err := json.Marshal(data)
    if err != nil {
        return err
    }
    _, err = js.Publish(subject, b)
    return err
}

func main() {
    natsURL := os.Getenv("NATS_URL")
    token := os.Getenv("IMOS_TOKEN")
    apiURL := os.Getenv("IMOS_API_URL")
    if apiURL == "" {
        apiURL = "https://example.com/imos" // placeholder
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
        data, err := fetchIMOS(ctx, client, apiURL, token)
        cancel()
        if err != nil {
            log.Printf("fetch error: %v", err)
        } else if err := publishWave(js, "waves.data", data); err != nil {
            log.Printf("publish error: %v", err)
        }
        <-ticker.C
    }
}

