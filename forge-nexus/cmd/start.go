package cmd

import (
	"fmt"
	"os"

	"github.com/NexusProtocol/forge-nexus/pkg/daemon"
	"github.com/spf13/cobra"
)

// startCmd represents the start command
var startCmd = &cobra.Command{
	Use:   "start",
	Short: "Starts the Nexus node service",
	Long: `Starts the systemd service for the Nexus node, allowing it to run
in the background. This command requires sudo privileges.`,
	Run: func(cmd *cobra.Command, args []string) {
		if err := daemon.Start(); err != nil {
			fmt.Fprintf(os.Stderr, "Error: %v\n", err)
			os.Exit(1)
		}
	},
}

func init() {
	rootCmd.AddCommand(startCmd)
}
