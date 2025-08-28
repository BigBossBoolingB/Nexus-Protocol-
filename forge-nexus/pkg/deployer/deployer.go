package deployer

import (
	"fmt"
	"io/ioutil"
	"os"
	"os/exec"
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

const serviceFileTemplate = `[Unit]
Description=Nexus Protocol Node
After=network.target

[Service]
# TODO: This should be run as a non-root user.
# User=nexus
# Group=nexus
Type=simple
ExecStart=%s
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
`

var binaryInstallPath = "/usr/local/bin/nexus-node" // Made a var for testing purposes
var serviceFilePath = "/etc/systemd/system/nexus-node.service" // Made a var for testing purposes

// Deploy performs all deployment steps for a given role and binary path.
func Deploy(tempBinaryPath, role string) error {
	fmt.Println("Starting deployment...")

	configPath, err := createConfigDir(role)
	if err != nil { return fmt.Errorf("could not create config directory: %w", err) }
	fmt.Printf(" ✓ Created config directory at %s\n", configPath)

	if err := writeDefaultConfig(configPath); err != nil { return fmt.Errorf("could not write default config: %w", err) }
	fmt.Printf(" ✓ Wrote default config to %s\n", filepath.Join(configPath, "config.toml"))

	if err := installBinary(tempBinaryPath); err != nil { return fmt.Errorf("could not install binary: %w", err) }
	fmt.Printf(" ✓ Installed node binary to %s\n", binaryInstallPath)

	if err := installServiceFile(); err != nil { return fmt.Errorf("could not install service file: %w", err) }
	fmt.Printf(" ✓ Installed systemd service file to %s\n", serviceFilePath)

	fmt.Println("Deployment successful.")
	return nil
}

// GetConfigPath determines the appropriate configuration directory path based on the role.
func GetConfigPath(role string) (string, error) {
	if role == "sentinel" { return "/etc/nexus", nil }
	home, err := os.UserHomeDir()
	if err != nil { return "", err }
	return filepath.Join(home, ".nexus"), nil
}

func createConfigDir(role string) (string, error) {
	configPath, err := GetConfigPath(role)
	if err != nil { return "", err }
	if err := os.MkdirAll(configPath, 0755); err != nil { return "", err }
	return configPath, nil
}

func writeDefaultConfig(configPath string) error {
	configFilePath := filepath.Join(configPath, "config.toml")
	if _, err := os.Stat(configFilePath); err == nil {
		fmt.Println("   - Config file already exists, skipping.")
		return nil
	}
	return ioutil.WriteFile(configFilePath, []byte(defaultConfig), 0644)
}

func installBinary(tempPath string) error {
	input, err := ioutil.ReadFile(tempPath)
	if err != nil { return fmt.Errorf("failed to read temporary binary: %w", err) }
	return ioutil.WriteFile(binaryInstallPath, input, 0755)
}

func installServiceFile() error {
	serviceFileContent := fmt.Sprintf(serviceFileTemplate, binaryInstallPath)
	if err := ioutil.WriteFile(serviceFilePath, []byte(serviceFileContent), 0644); err != nil {
		return fmt.Errorf("failed to write service file: %w", err)
	}

	// Reload systemd to recognize the new service.
	fmt.Println("   - Reloading systemd daemon...")
	// This command needs to be run as root. The SDK will need sudo privileges.
	cmd := exec.Command("systemctl", "daemon-reload")
	if err := cmd.Run(); err != nil {
		fmt.Println("     Warning: `systemctl daemon-reload` failed. You may need to run it manually with sudo.")
	}
	return nil
}
