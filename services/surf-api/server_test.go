package surfapi

import (
    "encoding/json"
    "net/http"
    "net/http/httptest"
    "testing"
)

type stubReporter struct{ msg string }

func (s stubReporter) Report() string { return s.msg }

func TestHealthzHandler(t *testing.T) {
    srv := NewServer(stubReporter{})
    req := httptest.NewRequest(http.MethodGet, "/healthz", nil)
    rr := httptest.NewRecorder()
    srv.ServeHTTP(rr, req)

    if rr.Code != http.StatusOK {
        t.Fatalf("expected status 200, got %d", rr.Code)
    }
    if body := rr.Body.String(); body != "ok" {
        t.Fatalf("unexpected body %q", body)
    }
}

func TestSurfHandlerUsesReporter(t *testing.T) {
    expected := "great waves"
    srv := NewServer(stubReporter{msg: expected})

    req := httptest.NewRequest(http.MethodGet, "/v1/surf", nil)
    rr := httptest.NewRecorder()
    srv.ServeHTTP(rr, req)

    if rr.Code != http.StatusOK {
        t.Fatalf("expected status 200, got %d", rr.Code)
    }

    var resp map[string]string
    if err := json.Unmarshal(rr.Body.Bytes(), &resp); err != nil {
        t.Fatalf("invalid JSON: %v", err)
    }
    if resp["report"] != expected {
        t.Fatalf("expected report %q, got %q", expected, resp["report"])
    }
}

