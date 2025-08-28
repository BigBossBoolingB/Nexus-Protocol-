package cmd

import (
	"fmt"
	"os"

	"github.com/NexusProtocol/forge-nexus/pkg/installer"
	"github.com/NexusProtocol/forge-nexus/pkg/osutil"
	"github.com/spf13/cobra"
)

var role string

// installCmd represents the install command
var installCmd = &cobra.Command{
	Use:   "install",
	Short: "Installs a Nexus Protocol node (Sentinel or Nomad)",
	Long: `This command installs the necessary software and dependencies for a node.
Use the --role flag to specify whether to install a 'sentinel' or 'nomad' node.`,
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Printf("Starting installation for role: %s\n", role)

		// 1. Detect the OS
		osID, err := osutil.DetectOS()
		if err != nil {
			// If we can't detect the OS, we can fall back or fail.
			// For now, we'll fail with a clear message.
			fmt.Printf("Error: Could not detect operating system: %v\n", err)
			fmt.Println("Installation cannot proceed without a supported OS.")
			os.Exit(1)
		}
		fmt.Printf("Detected OS: %s\n", osID)

		// 2. Select the appropriate installer (Factory Pattern)
		var inst installer.Installer
		switch osID {
		case "ubuntu":
			inst = &installer.UbuntuInstaller{}
		case "centos":
			inst = &installer.CentOSInstaller{}
		default:
			inst = &installer.UnsupportedInstaller{OS_ID: osID}
		}

		// 3. Run the installation
		fmt.Println("Handing off to OS-specific installer...")
		if err := inst.Install(); err != nil {
			fmt.Printf("Installation failed: %v\n", err)
			os.Exit(1)
		}

		fmt.Println("\nInstallation tasks successfully completed.")
	},
}

func init() {
	rootCmd.AddCommand(installCmd)
	installCmd.Flags().StringVarP(&role, "role", "r", "", "The role of the node to install ('sentinel' or 'nomad')")
	installCmd.MarkFlagRequired("role")
}
