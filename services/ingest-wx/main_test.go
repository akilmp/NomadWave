package main

import (
    "context"
    "encoding/json"
    "fmt"
    "net/http"
    "net/http/httptest"
    "reflect"
    "testing"
    "time"

    natsserver "github.com/nats-io/nats-server/v2/server"
    "github.com/nats-io/nats.go"
)

func TestFetchBOM(t *testing.T) {
    expected := BOMWeather{Station: "XYZ", Temperature: 20.5}
    srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        json.NewEncoder(w).Encode(expected)
    }))
    defer srv.Close()

    client := srv.Client()
    got, err := fetchBOM(context.Background(), client, srv.URL, "token")
    if err != nil {
        t.Fatalf("fetchBOM error: %v", err)
    }
    if !reflect.DeepEqual(got, expected) {
        t.Fatalf("got %+v, want %+v", got, expected)
    }
}

func runTestServer() (*natsserver.Server, error) {
    opts := &natsserver.Options{Port: -1, JetStream: true}
    s, err := natsserver.NewServer(opts)
    if err != nil {
        return nil, err
    }
    go s.Start()
    if !s.ReadyForConnections(10 * time.Second) {
        return nil, fmt.Errorf("server not ready")
    }
    return s, nil
}

func TestPublishWeather(t *testing.T) {
    s, err := runTestServer()
    if err != nil {
        t.Fatalf("server start: %v", err)
    }
    defer s.Shutdown()

    nc, err := nats.Connect(s.ClientURL())
    if err != nil {
        t.Fatalf("connect: %v", err)
    }
    defer nc.Drain()

    js, err := nc.JetStream()
    if err != nil {
        t.Fatalf("jetstream: %v", err)
    }

    _, err = js.AddStream(&nats.StreamConfig{Name: "WX", Subjects: []string{"weather.data"}})
    if err != nil {
        t.Fatalf("add stream: %v", err)
    }

    data := BOMWeather{Station: "XYZ", Temperature: 20.5}
    if err := publishWeather(js, "weather.data", data); err != nil {
        t.Fatalf("publish: %v", err)
    }

    sub, err := js.PullSubscribe("weather.data", "dur")
    if err != nil {
        t.Fatalf("subscribe: %v", err)
    }

    msgs, err := sub.Fetch(1, nats.MaxWait(2*time.Second))
    if err != nil {
        t.Fatalf("fetch: %v", err)
    }

    var got BOMWeather
    if err := json.Unmarshal(msgs[0].Data, &got); err != nil {
        t.Fatalf("unmarshal: %v", err)
    }
    if !reflect.DeepEqual(got, data) {
        t.Fatalf("got %+v, want %+v", got, data)
    }
}

