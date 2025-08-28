package daemon

import (
	"fmt"
	"os/exec"
)

const serviceName = "nexus-node.service"

// Executor defines an interface for running external commands.
// This allows for mocking in tests.
type Executor interface
	Run(command string, args ...string) ([]byte, error)
}

// RealExecutor is the production implementation of the Executor interface.
type RealExecutor struct{}

// Run executes a command using os/exec.
func (e *RealExecutor) Run(command string, args ...string) ([]byte, error) {
	return exec.Command(command, args...).CombinedOutput()
}

// a private variable to hold the executor instance.
var executor Executor = &RealExecutor{}

// Start attempts to start the nexus-node systemd service.
func Start() error {
	fmt.Printf("Attempting to start %s...\n", serviceName)
	output, err := executor.Run("systemctl", "start", serviceName)
	if err != nil {
		return fmt.Errorf("failed to start service: %s\n%v", string(output), err)
	}
	fmt.Printf("✓ Service %s started.\n", serviceName)
	return nil
}

// Stop attempts to stop the nexus-node systemd service.
func Stop() error {
	fmt.Printf("Attempting to stop %s...\n", serviceName)
	output, err := executor.Run("systemctl", "stop", serviceName)
	if err != nil {
		return fmt.Errorf("failed to stop service: %s\n%v", string(output), err)
	}
	fmt.Printf("✓ Service %s stopped.\n", serviceName)
	return nil
}

// Status attempts to get the status of the nexus-node systemd service.
func Status() (string, error) {
	fmt.Printf("Checking status of %s...\n", serviceName)
	output, err := executor.Run("systemctl", "status", serviceName)
	if err != nil {
		// `systemctl status` returns a non-zero exit code if the service is not active.
		// We can still return the output to the user in this case.
		return string(output), err
	}
	return string(output), nil
}
