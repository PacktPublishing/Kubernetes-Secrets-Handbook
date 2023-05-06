package main

import (
    "fmt"
	"log"
    "net/http"
)

func main() {

	// print the hello message with the URL path 
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
        fmt.Fprintf(w, "Hello from URL path: %s\n", r.URL.Path)

		// if URL path is root - propose a test
		if r.URL.Path == "/" {
			fmt.Fprintf(w, "Try to add /packt as a path.")
		}

		// print the URL path at the console
		if r.URL.Path != "/favicon.ico" {
			fmt.Printf("User requested the URL path: %s\n", r.URL.Path)
		}
    })

	// print message at the console
	fmt.Println("Kubernetes Secret Management Handbook - Chapter 1 - Example 1 - Hello World")
	fmt.Println("--> Server running on http://localhost:8080")

	// start the service and listen on the given port
    if err := http.ListenAndServe(":8080", nil); err != nil {
		// print error messages at the console
		log.Fatal(err)
	}
}