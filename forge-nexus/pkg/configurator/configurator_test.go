package configurator

import (
	"strings"
	"testing"
)

func TestGenerateTOMLString(t *testing.T) {
	cfg := Config{
		P2P_ListenPort: 8888,
		RPC_ListenPort: 9999,
		NodeAlias:      "My Test Node",
	}

	tomlString, err := generateTOMLString(cfg)
	if err != nil {
		t.Fatalf("generateTOMLString returned an error: %v", err)
	}

	// Check for key parts of the output to ensure the template is working
	if !strings.Contains(tomlString, "listen_port = 8888") {
		t.Error("TOML string does not contain correct P2P port")
	}
	if !strings.Contains(tomlString, "listen_port = 9999") {
		t.Error("TOML string does not contain correct RPC port")
	}
	if !strings.Contains(tomlString, "alias = \"My Test Node\"") {
		t.Error("TOML string does not contain correct alias")
	}
}
