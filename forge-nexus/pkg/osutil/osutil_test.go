package osutil

import (
	"io/ioutil"
	"os"
	"path/filepath"
	"testing"
)

func TestDetectOS(t *testing.T) {
	// --- Test Case 1: Standard Ubuntu file ---
	t.Run("should detect ubuntu from standard file", func(t *testing.T) {
		content := []byte("NAME=\"Ubuntu\"\nVERSION=\"20.04.3 LTS (Focal Fossa)\"\nID=ubuntu\nID_LIKE=debian\nPRETTY_NAME=\"Ubuntu 20.04.3 LTS\"")
		tmpfile, cleanup := createTempOSRelease(t, content)
		defer cleanup()

		osReleaseFile = tmpfile.Name() // Override the path for this test

		osID, err := DetectOS()
		if err != nil {
			t.Fatalf("DetectOS() returned an error: %v", err)
		}
		if osID != "ubuntu" {
			t.Errorf("expected osID to be 'ubuntu', but got '%s'", osID)
		}
	})

	// --- Test Case 2: File with quoted values ---
	t.Run("should detect centos from file with quotes", func(t *testing.T) {
		content := []byte("NAME=\"CentOS Linux\"\nID=\"centos\"\nVERSION_ID=\"8\"")
		tmpfile, cleanup := createTempOSRelease(t, content)
		defer cleanup()

		osReleaseFile = tmpfile.Name()

		osID, err := DetectOS()
		if err != nil {
			t.Fatalf("DetectOS() returned an error: %v", err)
		}
		if osID != "centos" {
			t.Errorf("expected osID to be 'centos', but got '%s'", osID)
		}
	})

	// --- Test Case 3: File missing the ID field ---
	t.Run("should return error if ID field is missing", func(t *testing.T) {
		content := []byte("NAME=\"Unknown Linux\"")
		tmpfile, cleanup := createTempOSRelease(t, content)
		defer cleanup()

		osReleaseFile = tmpfile.Name()

		_, err := DetectOS()
		if err == nil {
			t.Error("expected an error when ID field is missing, but got nil")
		}
	})

	// --- Test Case 4: File does not exist ---
	t.Run("should return error if file does not exist", func(t *testing.T) {
		osReleaseFile = "/tmp/this/file/does/not/exist"
		_, err := DetectOS()
		if err == nil {
			t.Error("expected an error when file does not exist, but got nil")
		}
	})
}

// createTempOSRelease is a helper function to create a temporary os-release file.
// It returns the file and a cleanup function to be called with defer.
func createTempOSRelease(t *testing.T, content []byte) (*os.File, func()) {
	t.Helper()
	tmpdir, err := ioutil.TempDir("", "osutil-test")
	if err != nil {
		t.Fatalf("failed to create temp dir: %v", err)
	}

	tmpfile, err := os.Create(filepath.Join(tmpdir, "os-release"))
	if err != nil {
		t.Fatalf("failed to create temp file: %v", err)
	}

	if _, err := tmpfile.Write(content); err != nil {
		t.Fatalf("failed to write to temp file: %v", err)
	}
	if err := tmpfile.Close(); err != nil {
		t.Fatalf("failed to close temp file: %v", err)
	}

	cleanup := func() {
		os.RemoveAll(tmpdir)
	}

	return tmpfile, cleanup
}
