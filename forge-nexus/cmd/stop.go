package cmd

import (
	"fmt"
	"os"

	"github.com/NexusProtocol/forge-nexus/pkg/daemon"
	"github.com/spf13/cobra"
)

// stopCmd represents the stop command
var stopCmd = &cobra.Command{
	Use:   "stop",
	Short: "Stops the Nexus node service",
	Long: `Stops the systemd service for the Nexus node.
This command requires sudo privileges.`,
	Run: func(cmd *cobra.Command, args []string) {
		if err := daemon.Stop(); err != nil {
			fmt.Fprintf(os.Stderr, "Error: %v\n", err)
			os.Exit(1)
		}
	},
}

func init() {
	rootCmd.AddCommand(stopCmd)
}
