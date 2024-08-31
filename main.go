package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"time"
)

type TimeResponse struct {
	Time string `json:"time"`
}

func getTime(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	currentTime := TimeResponse{Time: time.Now().UTC().Format(time.RFC3339)}
	json.NewEncoder(w).Encode(currentTime)
}

