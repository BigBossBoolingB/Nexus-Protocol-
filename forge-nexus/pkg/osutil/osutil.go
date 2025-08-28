package osutil

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

var osReleaseFile = "/etc/os-release" // Made a var for testing purposes

// DetectOS attempts to identify the host operating system by parsing the
// /etc/os-release file. It looks for the "ID" field.
// It returns the OS ID (e.g., "ubuntu", "centos") or an error if it fails.
func DetectOS() (string, error) {
	file, err := os.Open(osReleaseFile)
	if err != nil {
		return "", err
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := scanner.Text()
		if strings.HasPrefix(line, "ID=") {
			// The line is in the format "ID=value" or "ID="value""
			value := strings.TrimPrefix(line, "ID=")
			value = strings.Trim(value, `"`)
			return value, nil
		}
	}

	if err := scanner.Err(); err != nil {
		return "", err
	}

	return "", fmt.Errorf("could not find ID field in %s", osReleaseFile)
}
