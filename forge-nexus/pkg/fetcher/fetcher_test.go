package fetcher

import (
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"net/http"
	"net/http/httptest"
	"os"
	"strings"
	"testing"
)

func TestBuildDownloadURL(t *testing.T) {
	testCases := []struct {
		name    string
		version string
		role    string
		os      string
		arch    string
		want    string
	}{
		{"Standard Sentinel", "v1.0.0", "sentinel", "linux", "amd64", "https://downloads.nexusprotocol.io/releases/v1.0.0/sentinel-linux-amd64"},
		{"Nomad on ARM", "latest", "nomad", "darwin", "arm64", "https://downloads.nexusprotocol.io/releases/latest/nomad-darwin-arm64"},
	}

	for _, tc := range testCases {
		t.Run(tc.name, func(t *testing.T) {
			originalBaseURL := BaseURL
			BaseURL = "https://downloads.nexusprotocol.io/releases" // Ensure consistent base for test
			defer func() { BaseURL = originalBaseURL }()

			got := BuildDownloadURL(tc.version, tc.role, tc.os, tc.arch)
			if got != tc.want {
				t.Errorf("BuildDownloadURL() = %v, want %v", got, tc.want)
			}
		})
	}
}

func TestFetchAndVerifyBinary(t *testing.T) {
	// --- Test Setup ---
	fakeBinaryContent := "this is a fake binary file"
	hash := sha256.New()
	hash.Write([]byte(fakeBinaryContent))
	correctChecksum := hex.EncodeToString(hash.Sum(nil))
	incorrectChecksum := "incorrectchecksum"

	// Mock HTTP Server
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if strings.HasSuffix(r.URL.Path, ".sha256") {
			// Serve checksum file
			if r.URL.Query().Get("fail") == "true" {
				w.Write([]byte(incorrectChecksum + "  somefile"))
			} else {
				w.Write([]byte(correctChecksum + "  somefile"))
			}
		} else {
			// Serve binary file
			w.Write([]byte(fakeBinaryContent))
		}
	}))
	defer server.Close()

	// Override BaseURL to point to our test server
	originalBaseURL := BaseURL
	BaseURL = server.URL
	defer func() { BaseURL = originalBaseURL }()

	// --- Test Cases ---
	t.Run("should succeed with matching checksum", func(t *testing.T) {
		filePath, err := FetchAndVerifyBinary("v1", "role", "os", "arch")
		if err != nil {
			t.Fatalf("FetchAndVerifyBinary() returned an error: %v", err)
		}
		defer os.Remove(filePath) // Clean up the downloaded temp file

		// Optional: check content of downloaded file
		content, _ := os.ReadFile(filePath)
		if string(content) != fakeBinaryContent {
			t.Error("Downloaded file content does not match expected content")
		}
	})

	t.Run("should fail with mismatched checksum", func(t *testing.T) {
		// We modify the request to the mock server to make it return a bad checksum
		// This is a bit of a hack; a more complex mock would inspect the path.
		// For now, we'll just modify the base URL for this one test.
		BaseURL = server.URL + "?fail=true"

		_, err := FetchAndVerifyBinary("v1", "role", "os", "arch")
		if err == nil {
			t.Fatal("FetchAndVerifyBinary() did not return an error for mismatched checksum")
		}
		if !strings.Contains(err.Error(), "checksum mismatch") {
			t.Errorf("Expected error to contain 'checksum mismatch', but got: %v", err)
		}
		BaseURL = server.URL // Reset for next test
	})
}
