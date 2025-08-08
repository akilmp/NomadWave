package carbonscaler

import (
	"net/http"
	"net/http/httptest"
	"testing"
)

// stubRunner captures commands for verification.
type stubRunner struct {
	cmd  string
	args []string
}

func (s *stubRunner) run(cmd string, args ...string) error {
	s.cmd = cmd
	s.args = args
	return nil
}

func TestScale_Drain(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte(`{"carbonIntensity":500}`))
	}))
	defer srv.Close()

	stub := &stubRunner{}
	err := Scale("node1", srv.URL, 400, 50, stub.run)
	if err != nil {
		t.Fatalf("Scale returned error: %v", err)
	}
	if stub.cmd != "nomad" {
		t.Fatalf("expected nomad command, got %s", stub.cmd)
	}
	expected := []string{"node", "drain", "-yes", "node1"}
	if len(stub.args) != len(expected) {
		t.Fatalf("expected args %v, got %v", expected, stub.args)
	}
	for i, arg := range expected {
		if stub.args[i] != arg {
			t.Fatalf("expected arg %s at %d, got %s", arg, i, stub.args[i])
		}
	}
}

func TestScale_SetWeight(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte(`{"carbonIntensity":200}`))
	}))
	defer srv.Close()

	stub := &stubRunner{}
	err := Scale("node1", srv.URL, 400, 25, stub.run)
	if err != nil {
		t.Fatalf("Scale returned error: %v", err)
	}
	expected := []string{"node", "update", "-weight", "25", "node1"}
	if len(stub.args) != len(expected) {
		t.Fatalf("expected args %v, got %v", expected, stub.args)
	}
	for i, arg := range expected {
		if stub.args[i] != arg {
			t.Fatalf("expected arg %s at %d, got %s", arg, i, stub.args[i])
		}
	}
}
