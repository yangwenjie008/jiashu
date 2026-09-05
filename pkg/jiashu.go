// Package jiashu provides the core functionality for the jiashu application.
package jiashu

import (
	"fmt"
	"runtime"
)

// Version returns the version of the application.
func Version() string {
	return "0.1.0"
}

// GetPlatform returns the current platform.
func GetPlatform() string {
	return fmt.Sprintf("%s/%s", runtime.GOOS, runtime.GOARCH)
}

// Initialize sets up the application.
func Initialize() error {
	// TODO: Initialize application components
	fmt.Printf("jiashu v%s initialized on %s\n", Version(), GetPlatform())
	return nil
}
