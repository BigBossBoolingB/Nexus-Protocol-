package deployer

import (
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"
)

const defaultConfig = `# Default configuration for a Nexus node.
# This file is in TOML format.

[p2p]
# Port for peer-to-peer communication
listen_port = 8787

[rpc]
# Port for the RPC API
listen_port = 8788
`

var binaryInstallPath = "/usr/local/bin/nexus-node" // Made a var for testing purposes

// Deploy performs all deployment steps for a given role and binary path.
func Deploy(tempBinaryPath, role string) error {
	fmt.Println("Starting deployment...")

	configPath, err := createConfigDir(role)
	if err != nil {
		return fmt.Errorf("could not create config directory: %w", err)
	}
	fmt.Printf(" ✓ Created config directory at %s\n", configPath)

	if err := writeDefaultConfig(configPath); err != nil {
		return fmt.Errorf("could not write default config: %w", err)
	}
	fmt.Printf(" ✓ Wrote default config to %s\n", filepath.Join(configPath, "config.toml"))

	if err := installBinary(tempBinaryPath); err != nil {
		return fmt.Errorf("could not install binary: %w", err)
	}
	fmt.Printf(" ✓ Installed node binary to %s\n", binaryInstallPath)

	fmt.Println("Deployment successful.")
	return nil
}

// GetConfigPath determines the appropriate configuration directory path based on the role.
func GetConfigPath(role string) (string, error) {
	if role == "sentinel" {
		return "/etc/nexus", nil
	}
	// Default to nomad
	home, err := os.UserHomeDir()
	if err != nil {
		return "", err
	}
	return filepath.Join(home, ".nexus"), nil
}

func createConfigDir(role string) (string, error) {
	configPath, err := GetConfigPath(role)
	if err != nil {
		return "", err
	}
	// os.MkdirAll is like `mkdir -p`, it creates parents and doesn't error if it exists.
	if err := os.MkdirAll(configPath, 0755); err != nil {
		return "", err
	}
	return configPath, nil
}

func writeDefaultConfig(configPath string) error {
	configFilePath := filepath.Join(configPath, "config.toml")
	// Check if file already exists to avoid overwriting user changes.
	if _, err := os.Stat(configFilePath); err == nil {
		fmt.Println("   - Config file already exists, skipping.")
		return nil
	}
	return ioutil.WriteFile(configFilePath, []byte(defaultConfig), 0644)
}

func installBinary(tempPath string) error {
	// Read the temporary binary file
	input, err := ioutil.ReadFile(tempPath)
	if err != nil {
		return fmt.Errorf("failed to read temporary binary: %w", err)
	}

	// Write the binary to the final destination with executable permissions
	if err := ioutil.WriteFile(binaryInstallPath, input, 0755); err != nil {
		return fmt.Errorf("failed to write binary to destination: %w", err)
	}

	// The temporary file will be removed by the caller (e.g., the fetcher)
	return nil
}
