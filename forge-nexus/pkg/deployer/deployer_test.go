package deployer

import (
	"io/ioutil"
	"os"
	"path/filepath"
	"testing"
)

// setupTestEnvironment creates a temporary directory structure for testing.
// It returns the paths to the temp home, bin, and a cleanup function.
func setupTestEnvironment(t *testing.T) (string, string, func()) {
	t.Helper()

	// Create a master temporary directory for the whole test
	testRoot, err := ioutil.TempDir("", "deployer-test-")
	if err != nil {
		t.Fatalf("Failed to create test root dir: %v", err)
	}

	// Create fake home and bin directories inside the test root
	homeDir := filepath.Join(testRoot, "home")
	binDir := filepath.Join(testRoot, "bin")
	os.Mkdir(homeDir, 0755)
	os.Mkdir(binDir, 0755)

	// Override the user's home directory for this test
	originalHome := os.Getenv("HOME")
	os.Setenv("HOME", homeDir)

	// Override the binary install path
	originalBinPath := binaryInstallPath
	binaryInstallPath = filepath.Join(binDir, "nexus-node")

	cleanup := func() {
		os.RemoveAll(testRoot)
		os.Setenv("HOME", originalHome)
		binaryInstallPath = originalBinPath
	}

	return homeDir, binDir, cleanup
}

func TestCreateConfigDir(t *testing.T) {
	homeDir, _, cleanup := setupTestEnvironment(t)
	defer cleanup()

	// Test for nomad role
	configPath, err := createConfigDir("nomad")
	if err != nil {
		t.Fatalf("createConfigDir failed for nomad: %v", err)
	}

	expectedPath := filepath.Join(homeDir, ".nexus")
	if configPath != expectedPath {
		t.Errorf("expected config path %s, got %s", expectedPath, configPath)
	}

	if _, err := os.Stat(expectedPath); os.IsNotExist(err) {
		t.Errorf(".nexus directory was not created at %s", expectedPath)
	}
}

func TestWriteDefaultConfig(t *testing.T) {
	_, _, cleanup := setupTestEnvironment(t)
	defer cleanup()

	// Create a temp dir to act as the config path
	tmpConfigDir, _ := ioutil.TempDir("", "config-test")
	defer os.RemoveAll(tmpConfigDir)

	configFilePath := filepath.Join(tmpConfigDir, "config.toml")

	// First write should succeed
	if err := writeDefaultConfig(tmpConfigDir); err != nil {
		t.Fatalf("writeDefaultConfig failed on first write: %v", err)
	}
	if _, err := os.Stat(configFilePath); os.IsNotExist(err) {
		t.Fatal("config.toml was not created")
	}

	// Second write should be skipped
	if err := writeDefaultConfig(tmpConfigDir); err != nil {
		t.Fatalf("writeDefaultConfig failed on second write: %v", err)
	}
}

func TestInstallBinary(t *testing.T) {
	_, binDir, cleanup := setupTestEnvironment(t)
	defer cleanup()

	// Create a fake temporary binary file
	fakeBinary, err := ioutil.TempFile("", "fake-binary")
	if err != nil {
		t.Fatalf("Failed to create fake binary: %v", err)
	}
	fakeBinary.WriteString("i am a binary")
	fakeBinary.Close()
	defer os.Remove(fakeBinary.Name())

	// Run the install function
	if err := installBinary(fakeBinary.Name()); err != nil {
		t.Fatalf("installBinary failed: %v", err)
	}

	// Check if the file was moved and is executable
	finalPath := filepath.Join(binDir, "nexus-node")
	info, err := os.Stat(finalPath)
	if os.IsNotExist(err) {
		t.Fatal("binary was not installed to the correct path")
	}
	if info.Mode().Perm() != 0755 {
		t.Errorf("binary has incorrect permissions: got %v, want %v", info.Mode().Perm(), os.FileMode(0755))
	}
}
