package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
)

// configureCmd represents the configure command
var configureCmd = &cobra.Command{
	Use:   "configure",
	Short: "Guides you through creating a configuration file for your node",
	Long: `This interactive command will ask you a series of questions to generate
a valid configuration file (config.toml) for your Nexus node.`,
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("configure called")
	},
}

func init() {
	rootCmd.AddCommand(configureCmd)
}
