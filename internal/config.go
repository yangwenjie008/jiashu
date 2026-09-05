// Package config provides configuration management for the application.
package config

import (
	"encoding/json"
	"os"
	"path/filepath"
)

// Config represents the application configuration.
type Config struct {
	AppName     string `json:"app_name"`
	Version     string `json:"version"`
	Debug       bool   `json:"debug"`
	Port        int    `json:"port"`
	DatabaseURL string `json:"database_url"`
}

// LoadConfig loads configuration from a file.
func LoadConfig(filename string) (*Config, error) {
	file, err := os.Open(filepath.Clean(filename))
	if err != nil {
		return nil, err
	}
	defer func() { _ = file.Close() }()

	decoder := json.NewDecoder(file)
	config := &Config{}
	if err := decoder.Decode(config); err != nil {
		return nil, err
	}

	return config, nil
}

// DefaultConfig returns a default configuration.
func DefaultConfig() *Config {
	return &Config{
		AppName: "jiashu",
		Version: "0.1.0",
		Debug:   false,
		Port:    8080,
	}
}
