package cmd

import (
	"fmt"
	"os"

	"github.com/NexusProtocol/forge-nexus/pkg/configurator"
	"github.com/spf13/cobra"
)

// configureCmd represents the configure command
var configureCmd = &cobra.Command{
	Use:   "configure",
	Short: "Guides you through creating a configuration file for your node",
	Long: `This interactive command will ask you a series of questions to generate
a valid configuration file (config.toml) for your Nexus node.
It can be run multiple times to overwrite existing settings.`,
	Run: func(cmd *cobra.Command, args []string) {
		if err := configurator.RunInteractive(role); err != nil {
			fmt.Fprintf(os.Stderr, "Error during configuration: %v\n", err)
			os.Exit(1)
		}
	},
}

func init() {
	rootCmd.AddCommand(configureCmd)

	// We use the same 'role' variable from install.go, which is fine as Cobra
	// flags are parsed based on the command being run. We'll give this one
	// a default value, as 'configure' might be run independently.
	configureCmd.Flags().StringVarP(&role, "role", "r", "nomad", "The role of the node to configure ('sentinel' or 'nomad')")
}
