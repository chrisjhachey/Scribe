package api

import (
	"fmt"
	"io/ioutil"
	"model"
	"net/http"

	"github.com/gorilla/mux"
)

func getTexts(w http.ResponseWriter, r *http.Request) {
	if model.ValidateToken(r) {
		params := mux.Vars(r)
		theID := params["userid"]

		theTexts, err := model.RetrieveTexts(theID)

		if err != nil {
			panic(err.Error())
		}

		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		w.Write([]byte(string(theTexts)))

		fmt.Println(string(theTexts))
	} else {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusUnauthorized)
		w.Write([]byte(`"message": "Unauthorized: token not provided or invalid!"`))
	}
}

func postText(w http.ResponseWriter, r *http.Request) {
	if model.ValidateToken(r) {
		bytes, err := ioutil.ReadAll(r.Body)

		if err != nil {
			panic(err.Error())
		}

		theText, err := model.CreateText(bytes)

		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusCreated)
		w.Write([]byte(string(theText)))
	}
}

func patchText(w http.ResponseWriter, r *http.Request) {
	if model.ValidateToken(r) {
		b, err := ioutil.ReadAll(r.Body)

		if err != nil {
			panic(err.Error())
		}

		thePassage, err := model.UpdateText(b)

		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusCreated)
		w.Write([]byte(string(thePassage)))
		//w.Write([]byte(`{"message": "Patch Called Successfully"}`))
		fmt.Println(string(thePassage))
	}
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
	router.HandleFunc("/text/{userid}", getTexts).Methods(http.MethodGet)
	router.HandleFunc("/text", postText).Methods(http.MethodPost)
	router.HandleFunc("/text", putText).Methods(http.MethodPut)
	router.HandleFunc("/text", patchText).Methods(http.MethodPatch)
	router.HandleFunc("/text/{textid}", deleteText).Methods(http.MethodDelete)
	router.HandleFunc("/text", notFoundText)
}
