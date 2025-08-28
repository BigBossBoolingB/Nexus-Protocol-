package cmd

import (
	"fmt"
	"os"

	"github.com/NexusProtocol/forge-nexus/pkg/deployer"
	"github.com/NexusProtocol/forge-nexus/pkg/fetcher"
	"github.com/NexusProtocol/forge-nexus/pkg/osutil"
	"github.com/spf13/cobra"
)

var role string
var version string

// installCmd represents the install command
var installCmd = &cobra.Command{
	Use:   "install",
	Short: "Installs a Nexus Protocol node (Sentinel or Nomad)",
	Long: `This command securely downloads and installs the necessary software
for a Nexus Protocol node. It detects the host OS and architecture,
downloads the appropriate binary, verifies its integrity, and deploys it.`,
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Printf(">>> Starting Nexus Protocol installation for role: %s, version: %s <<<\n", role, version)

		// 1. Detect Host Environment
		fmt.Println("--- Detecting host environment...")
		osID, err := osutil.DetectOS()
		if err != nil {
			fmt.Fprintf(os.Stderr, "Error: Could not detect operating system: %v\n", err)
			os.Exit(1)
		}
		arch := osutil.DetectArch()
		fmt.Printf(" ✓ Detected System: %s/%s\n", osID, arch)

		// 2. Acquire the Binary
		fmt.Println("\n--- Acquiring node binary...")
		tempBinaryPath, err := fetcher.FetchAndVerifyBinary(version, role, osID, arch)
		if err != nil {
			fmt.Fprintf(os.Stderr, "Error acquiring binary: %v\n", err)
			os.Exit(1)
		}
		defer os.Remove(tempBinaryPath) // Ensure temp file is cleaned up on exit

		// 3. Deploy the Binary and Configuration
		fmt.Println("\n--- Deploying node and configuration...")
		if err := deployer.Deploy(tempBinaryPath, role); err != nil {
			fmt.Fprintf(os.Stderr, "Error deploying node: %v\n", err)
			os.Exit(1)
		}

		fmt.Println("\n>>> Nexus Protocol installation complete! <<<")
		fmt.Println("To start your node, run: 'forge-nexus start'")
	},
}

func init() {
	rootCmd.AddCommand(installCmd)
	installCmd.Flags().StringVarP(&role, "role", "r", "", "The role of the node to install ('sentinel' or 'nomad')")
	installCmd.Flags().StringVarP(&version, "version", "v", "latest", "The version of the node to install (e.g., 'v1.2.0', 'latest')")
	installCmd.MarkFlagRequired("role")
}
