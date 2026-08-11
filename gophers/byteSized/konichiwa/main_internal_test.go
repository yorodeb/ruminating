package main

import (
	"testing"
)

func TestGreet(t *testing.T) {
	expectedOut := "Hello, World!"

	actualOut := greet()
	if actualOut != expectedOut {
		t.Errorf("Expected: %q, Actual: %q", expectedOut, actualOut)
	}
}
