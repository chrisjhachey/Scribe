//
//  Text.go
//  Scribe
//
//  Created by Christopher Hachey on 2020-02-13.
//  Copyright © 2020 Christopher Hachey. All rights reserved.
//

package api

import (
	"io/ioutil"
	"model"
	"net/http"

	"github.com/gorilla/mux"
)

func getPassages(w http.ResponseWriter, r *http.Request) {
	thePassages, err := model.GetPassages()

	if err != nil {
		panic(err.Error())
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	w.Write([]byte(string(thePassages)))
}

func postPassage(w http.ResponseWriter, r *http.Request) {
	b, err := ioutil.ReadAll(r.Body)

	if err != nil {
		panic(err)
	}

	model.CreatePassage(b)

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	w.Write([]byte(`{"message": "post called on Passage"}`))
}

func putPassage(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusAccepted)
	w.Write([]byte(`{"message": "put called on Passge"}`))
}

func deletePassage(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	w.Write([]byte(`{"message": "delete called on Passage"}`))
}

func notFoundPassage(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusNotFound)
	w.Write([]byte(`{"message": "not found for Passage"}`))
}

// SetPassageHandlerFunctions sets the handler functions for the Router and adds a matcher for the HTTP verb
func SetPassageHandlerFunctions(router *mux.Router) {
	router.HandleFunc("/passage", getPassages).Methods(http.MethodGet)
	router.HandleFunc("/passage", postPassage).Methods(http.MethodPost)
	router.HandleFunc("/passage", putPassage).Methods(http.MethodPut)
	router.HandleFunc("/passage", deletePassage).Methods(http.MethodDelete)
	router.HandleFunc("/passage", notFoundPassage)
}
