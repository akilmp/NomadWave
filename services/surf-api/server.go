package surfapi

import (
    "encoding/json"
    "net/http"
)

// Reporter provides surf condition data.
type Reporter interface {
    Report() string
}

// Server handles HTTP requests.
type Server struct {
    reporter Reporter
    mux      *http.ServeMux
}

// NewServer wires dependencies and returns a Server.
func NewServer(r Reporter) *Server {
    s := &Server{reporter: r, mux: http.NewServeMux()}
    s.routes()
    return s
}

// ServeHTTP implements http.Handler.
func (s *Server) ServeHTTP(w http.ResponseWriter, r *http.Request) {
    s.mux.ServeHTTP(w, r)
}

func (s *Server) routes() {
    s.mux.HandleFunc("/healthz", s.healthHandler)
    s.mux.HandleFunc("/v1/surf", s.surfHandler)
}

func (s *Server) healthHandler(w http.ResponseWriter, r *http.Request) {
    w.WriteHeader(http.StatusOK)
    _, _ = w.Write([]byte("ok"))
}

func (s *Server) surfHandler(w http.ResponseWriter, r *http.Request) {
    resp := map[string]string{"report": s.reporter.Report()}
    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(resp)
}

// StaticReporter is a basic Reporter implementation.
type StaticReporter struct{}

func (StaticReporter) Report() string { return "flat" }
