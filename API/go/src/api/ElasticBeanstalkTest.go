package api

import (
	"net/http"

	"github.com/gorilla/mux"
)

func testEndpoint(w http.ResponseWriter, r *http.Request) {
	http.FileServer(http.Dir("./static"))
	// w.Header().Set("Content-Type", "application/json")
	// w.WriteHeader(http.StatusUnauthorized)
	// w.Write([]byte(`"message": "You just hit the test endpoint!"`))
}

// SetTestHandlerFunctions sets the handler functions for the Router and adds a matcher for the HTTP verb
func SetTestHandlerFunctions(router *mux.Router) {
	router.HandleFunc("/test", testEndpoint)
}
