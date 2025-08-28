package prompt

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

// Ask displays a question to the user and returns their input.
// If the user provides no input (i.e., just presses Enter), the
// defaultValue is returned.
func Ask(question string, defaultValue string) string {
	reader := bufio.NewReader(os.Stdin)

	if defaultValue == "" {
		fmt.Printf("%s: ", question)
	} else {
		fmt.Printf("%s [%s]: ", question, defaultValue)
	}

	input, err := reader.ReadString('\n')
	if err != nil {
		// If we can't read from stdin, we can't proceed.
		// A more robust CLI might handle this differently, but for now,
		// returning the default is a safe fallback.
		return defaultValue
	}

	input = strings.TrimSpace(input)

	if input == "" {
		return defaultValue
	}
	return input
}
