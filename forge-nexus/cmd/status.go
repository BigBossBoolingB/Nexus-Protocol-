package cmd

import (
	"fmt"
	"os"

	"github.com/NexusProtocol/forge-nexus/pkg/daemon"
	"github.com/spf13/cobra"
)

// statusCmd represents the status command
var statusCmd = &cobra.Command{
	Use:   "status",
	Short: "Shows the status of the Nexus node service",
	Long: `Checks and displays the current status of the systemd service
for the Nexus node (e.g., active, inactive, failed).`,
	Run: func(cmd *cobra.Command, args []string) {
		status, err := daemon.Status()
		if err != nil {
			// `systemctl status` returns a non-zero exit code on inactive/failed states,
			// which Go treats as an error. We still want to print the status output.
			fmt.Println(status)
			os.Exit(1)
		}
		fmt.Println(status)
	},
}

func init() {
	rootCmd.AddCommand(statusCmd)
}
