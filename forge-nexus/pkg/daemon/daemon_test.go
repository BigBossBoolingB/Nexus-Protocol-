package daemon

import (
	"fmt"
	"strings"
	"testing"
)

// MockExecutor is a mock implementation of the Executor interface for testing.
type MockExecutor struct {
	// A function that can be customized by each test to check the command.
	commandVerifier func(command string, args ...string)

	// What the mock should return
	outputToReturn []byte
	errorToReturn  error
}

// Run captures the command and args and returns the pre-configured output/error.
func (m *MockExecutor) Run(command string, args ...string) ([]byte, error) {
	if m.commandVerifier != nil {
		m.commandVerifier(command, args...)
	}
	return m.outputToReturn, m.errorToReturn
}

func TestStart(t *testing.T) {
	mock := &MockExecutor{}
	mock.commandVerifier = func(command string, args ...string) {
		if command != "systemctl" {
			t.Errorf("Expected command to be 'systemctl', got '%s'", command)
		}
		expectedArgs := []string{"start", serviceName}
		if !equalSlices(args, expectedArgs) {
			t.Errorf("Expected args %v, got %v", expectedArgs, args)
		}
	}
	executor = mock // Inject the mock

	if err := Start(); err != nil {
		t.Errorf("Start() returned an unexpected error: %v", err)
	}
}

func TestStop(t *testing.T) {
	mock := &MockExecutor{}
	mock.commandVerifier = func(command string, args ...string) {
		if command != "systemctl" {
			t.Errorf("Expected command to be 'systemctl', got '%s'", command)
		}
		expectedArgs := []string{"stop", serviceName}
		if !equalSlices(args, expectedArgs) {
			t.Errorf("Expected args %v, got %v", expectedArgs, args)
		}
	}
	executor = mock // Inject the mock

	if err := Stop(); err != nil {
		t.Errorf("Stop() returned an unexpected error: %v", err)
	}
}

func TestStatus(t *testing.T) {
	mock := &MockExecutor{
		outputToReturn: []byte("active"),
	}
	mock.commandVerifier = func(command string, args ...string) {
		if command != "systemctl" {
			t.Errorf("Expected command to be 'systemctl', got '%s'", command)
		}
		expectedArgs := []string{"status", serviceName}
		if !equalSlices(args, expectedArgs) {
			t.Errorf("Expected args %v, got %v", expectedArgs, args)
		}
	}
	executor = mock // Inject the mock

	status, err := Status()
	if err != nil {
		t.Errorf("Status() returned an unexpected error: %v", err)
	}
	if status != "active" {
		t.Errorf("Expected status 'active', got '%s'", status)
	}
}

// equalSlices is a helper to compare two string slices.
func equalSlices(a, b []string) bool {
	if len(a) != len(b) {
		return false
	}
	for i, v := range a {
		if v != b[i] {
			return false
		}
	}
	return true
}
