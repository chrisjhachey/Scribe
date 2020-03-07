package api

import (
	"fmt"
	"io/ioutil"
	"model"
	"net/http"

	"github.com/gorilla/mux"
)

func getTexts(w http.ResponseWriter, r *http.Request) {
	theTexts, err := model.RetrieveTexts()

	if err != nil {
		panic(err.Error())
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	w.Write([]byte(string(theTexts)))

	fmt.Println(string(theTexts))
}

func postText(w http.ResponseWriter, r *http.Request) {
	bytes, err := ioutil.ReadAll(r.Body)

	if err != nil {
		panic(err.Error())
	}

	theText, err := model.CreateText(bytes)

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	w.Write([]byte(string(theText)))
	//w.Write([]byte(`{"message": "Post Called Successfully"}`))

	//fmt.Println(string(theText))
}

func putText(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusAccepted)
	w.Write([]byte(`{"message": "put called on Text"}`))
}

func deleteText(w http.ResponseWriter, r *http.Request) {
	params := mux.Vars(r)
	theID := params["textid"]
	err := model.DeleteText(theID)

	if err != nil {
		panic(err.Error())
	}
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(204)
	fmt.Println("Delete called on Text", theID)
}

func notFoundText(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusNotFound)
	w.Write([]byte(`{"message": "not found for Text"}`))
}

// SetTextHandlerFunctions sets the handler functions for the Router and adds a matcher for the HTTP verb
func SetTextHandlerFunctions(router *mux.Router) {
	router.HandleFunc("/text", getTexts).Methods(http.MethodGet)
	router.HandleFunc("/text", postText).Methods(http.MethodPost)
	router.HandleFunc("/text", putText).Methods(http.MethodPut)
	router.HandleFunc("/text/{textid}", deleteText).Methods(http.MethodDelete)
	router.HandleFunc("/text", notFoundText)
}
