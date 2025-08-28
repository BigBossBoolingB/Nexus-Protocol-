package prompt

import (
	"io"
	"os"
	"strings"
	"testing"
)

func TestAsk(t *testing.T) {
	// --- Test Case 1: User provides input ---
	t.Run("should return user input when provided", func(t *testing.T) {
		input := "user input\n"
		reader, writer, err := os.Pipe()
		if err != nil {
			t.Fatal(err)
		}

		// Replace stdin and restore after the test
		originalStdin := os.Stdin
		os.Stdin = reader
		defer func() { os.Stdin = originalStdin }()

		// Write the test input to the pipe
		writer.WriteString(input)
		writer.Close()

		// Call the function and check the result
		result := Ask("Test question", "default")
		if result != "user input" {
			t.Errorf("expected 'user input', got '%s'", result)
		}
	})

	// --- Test Case 2: User provides no input (hits enter) ---
	t.Run("should return default value when input is empty", func(t *testing.T) {
		input := "\n"
		reader, writer, err := os.Pipe()
		if err != nil {
			t.Fatal(err)
		}

		originalStdin := os.Stdin
		os.Stdin = reader
		defer func() { os.Stdin = originalStdin }()

		writer.WriteString(input)
		writer.Close()

		result := Ask("Test question", "default")
		if result != "default" {
			t.Errorf("expected 'default', got '%s'", result)
		}
	})
}
