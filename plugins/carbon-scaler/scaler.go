package carbonscaler

import (
	"encoding/json"
	"fmt"
	"net/http"
	"os/exec"
)

// IntensityResponse models a minimal carbon intensity API response.
type IntensityResponse struct {
	CarbonIntensity int `json:"carbonIntensity"`
}

// FetchIntensity retrieves the current carbon intensity from the supplied API URL.
func FetchIntensity(url string) (int, error) {
	resp, err := http.Get(url)
	if err != nil {
		return 0, err
	}
	defer resp.Body.Close()

	var data IntensityResponse
	if err := json.NewDecoder(resp.Body).Decode(&data); err != nil {
		return 0, err
	}
	return data.CarbonIntensity, nil
}

// CommandRunner defines the function signature used to execute commands.
type CommandRunner func(cmd string, args ...string) error

// defaultRunner executes the provided command on the local system.
func defaultRunner(cmd string, args ...string) error {
	c := exec.Command(cmd, args...)
	return c.Run()
}

// Scale evaluates the current carbon intensity and either drains a node or
// adjusts its weight using the Nomad CLI.
//
// If the intensity exceeds the threshold, the node is drained; otherwise the
// node weight is set to the provided value.
func Scale(nodeID, apiURL string, threshold, weight int, runner CommandRunner) error {
	if runner == nil {
		runner = defaultRunner
	}
	intensity, err := FetchIntensity(apiURL)
	if err != nil {
		return err
	}
	if intensity > threshold {
		return runner("nomad", "node", "drain", "-yes", nodeID)
	}
	return runner("nomad", "node", "update", "-weight", fmt.Sprint(weight), nodeID)
}
