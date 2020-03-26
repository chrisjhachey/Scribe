package main

import (
	"api"
	"log"
	"net/http"

	_ "github.com/go-sql-driver/mysql"
	"github.com/gorilla/mux"
)

func main() {
	// Creates a new Router which registers Routes to be matched with an HTTP verb and dispatched to a handler.
	r := mux.NewRouter()

	// Registers a new Route with the given path prefix and creates a Subrouter for the Route.
	sr := r.PathPrefix("/api/v1").Subrouter()

	// Sets the handler functions for each resource
	api.SetTextHandlerFunctions(sr)
	api.SetPassageHandlerFunctions(sr)
	api.SetUserHandlerFunctions(sr)
	api.SetTokenHandlerFunctions(sr)
	api.SetRefreshHandlerFunctions(sr)

	// Listens on the TCP network address and then calls Serve with handler to handle requests on incoming connections
	log.Fatal(http.ListenAndServe(":5000", r))
}
