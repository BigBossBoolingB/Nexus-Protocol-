package fetcher

import (
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"io"
	"net/http"
	"os"
	"strings"
)

var BaseURL = "https://downloads.nexusprotocol.io/releases" // Made a var for testing purposes

// BuildDownloadURL constructs the expected download URL for a binary.
func BuildDownloadURL(version, role, os, arch string) string {
	return fmt.Sprintf("%s/%s/%s-%s-%s", BaseURL, version, role, os, arch)
}

// FetchAndVerifyBinary downloads a binary and its checksum, then verifies integrity.
// It returns the path to the verified binary file or an error.
func FetchAndVerifyBinary(version, role, os, arch string) (string, error) {
	binaryURL := BuildDownloadURL(version, role, os, arch)
	checksumURL := binaryURL + ".sha256"

	fmt.Printf("Downloading binary from %s...\n", binaryURL)
	tmpFile, err := downloadToTemp(binaryURL)
	if err != nil {
		return "", fmt.Errorf("failed to download binary: %w", err)
	}
	// Note: In a real app, we might not want to defer the remove,
	// but rather return the path and let the caller manage the file.
	// For this architecture, we'll assume it's moved before being removed.

	fmt.Printf("Downloading checksum from %s...\n", checksumURL)
	expectedSum, err := downloadChecksum(checksumURL)
	if err != nil {
		os.Remove(tmpFile.Name())
		return "", fmt.Errorf("failed to download checksum: %w", err)
	}

	fmt.Println("Verifying file integrity...")
	actualSum, err := computeSHA256(tmpFile.Name())
	if err != nil {
		os.Remove(tmpFile.Name())
		return "", fmt.Errorf("failed to compute hash of downloaded file: %w", err)
	}

	if actualSum != expectedSum {
		os.Remove(tmpFile.Name())
		return "", fmt.Errorf("checksum mismatch: expected %s, got %s. The binary may be tampered with or corrupted. Deleting.", expectedSum, actualSum)
	}

	fmt.Println("Verification successful. Binary is authentic.")
	return tmpFile.Name(), nil
}

func downloadToTemp(url string) (*os.File, error) {
	resp, err := http.Get(url)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("bad status: %s", resp.Status)
	}

	tmpFile, err := os.CreateTemp("", "forge-nexus-binary-")
	if err != nil {
		return nil, err
	}

	_, err = io.Copy(tmpFile, resp.Body)
	if err != nil {
		tmpFile.Close()
		os.Remove(tmpFile.Name())
		return nil, err
	}

	return tmpFile, nil
}

func downloadChecksum(url string) (string, error) {
	resp, err := http.Get(url)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("bad status: %s", resp.Status)
	}

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", err
	}

	// Checksum file format is typically "checksum  filename"
	fields := strings.Fields(string(body))
	if len(fields) == 0 {
		return "", fmt.Errorf("checksum file is empty or malformed")
	}
	return fields[0], nil
}

func computeSHA256(filePath string) (string, error) {
	file, err := os.Open(filePath)
	if err != nil {
		return "", err
	}
	defer file.Close()

	hash := sha256.New()
	if _, err := io.Copy(hash, file); err != nil {
		return "", err
	}

	return hex.EncodeToString(hash.Sum(nil)), nil
}
