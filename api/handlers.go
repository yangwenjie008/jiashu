// Package api provides API handlers for the application.
package api

import (
	"encoding/json"
	"net/http"
)

// HealthResponse represents a health check response.
type HealthResponse struct {
	Status string `json:"status"`
	Version string `json:"version"`
}

// HealthHandler handles health check requests.
func HealthHandler(w http.ResponseWriter, r *http.Request) {
	response := HealthResponse{
		Status: "ok",
		Version: "0.1.0",
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

// SetupRoutes sets up the API routes.
func SetupRoutes(mux *http.ServeMux) {
	mux.HandleFunc("/health", HealthHandler)
}
