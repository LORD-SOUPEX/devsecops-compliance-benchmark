package main

import (
	"fmt"
	"net/http"
	"os"
)

func main() {
	resp, _ := http.Get("http://localhost:8000/health")
	os.Remove("/tmp/health.lock")
	fmt.Println(resp.Status)
}
