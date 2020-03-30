package api

import (
	"io/ioutil"
	"model"
	"net/http"

	"github.com/gorilla/mux"
)

func getUsage(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusNotFound)
	w.Write([]byte(`{"message": "GET called on Usage"}`))
}

func postUsage(w http.ResponseWriter, r *http.Request) {
	if model.ValidateToken(r) {
		bytes, err := ioutil.ReadAll(r.Body)

		if err != nil {
			panic(err.Error())
		}

		theEntry, err := model.CreateUsageEntry(bytes)

		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusCreated)
		w.Write([]byte(string(theEntry)))
	}
}

func patchUsage(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusNotFound)
	w.Write([]byte(`{"message": "PATCH called on Usage"}`))
}

func putUsage(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusAccepted)
	w.Write([]byte(`{"message": "PUT called on Usage"}`))
}

func deleteUsage(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusAccepted)
	w.Write([]byte(`{"message": "DELETE called on Usage"}`))
}

func notFoundUsage(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusNotFound)
	w.Write([]byte(`{"message": "not found for Usage"}`))
}

// SetUsageHandlerFunctions sets the handler functions for the Router and adds a matcher for the HTTP verb
func SetUsageHandlerFunctions(router *mux.Router) {
	router.HandleFunc("/usage/{userid}", getUsage).Methods(http.MethodGet)
	router.HandleFunc("/usage", postUsage).Methods(http.MethodPost)
	router.HandleFunc("/usage", putUsage).Methods(http.MethodPut)
	router.HandleFunc("/usage", patchUsage).Methods(http.MethodPatch)
	router.HandleFunc("/usage", deleteUsage).Methods(http.MethodDelete)
	router.HandleFunc("/usage", notFoundUsage)
}
