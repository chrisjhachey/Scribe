package api

import (
	"fmt"
	"io/ioutil"
	"model"
	"net/http"

	"github.com/gorilla/mux"
)

func getTexts(w http.ResponseWriter, r *http.Request) {
<<<<<<< HEAD
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
	b, err := ioutil.ReadAll(r.Body)

	if err != nil {
		panic(err)
	}

	model.CreateText(b)

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	w.Write([]byte(`{"message": "post called on Text"}`))

	//fmt.Println(string(b))
=======
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
>>>>>>> UserAuth
}

func putText(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusAccepted)
	w.Write([]byte(`{"message": "put called on Text"}`))
}

func deleteText(w http.ResponseWriter, r *http.Request) {
<<<<<<< HEAD
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	w.Write([]byte(`{"message": "delete called on Text"}`))
=======
	params := mux.Vars(r)
	theID := params["textid"]
	err := model.DeleteText(theID)

	if err != nil {
		panic(err.Error())
	}
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(204)
	fmt.Println("Delete called on Text", theID)
>>>>>>> UserAuth
}

func notFoundText(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusNotFound)
	w.Write([]byte(`{"message": "not found for Text"}`))
}

// SetTextHandlerFunctions sets the handler functions for the Router and adds a matcher for the HTTP verb
func SetTextHandlerFunctions(router *mux.Router) {
<<<<<<< HEAD
	router.HandleFunc("/text", getTexts).Methods(http.MethodGet)
	router.HandleFunc("/text", postText).Methods(http.MethodPost)
	router.HandleFunc("/text", putText).Methods(http.MethodPut)
	router.HandleFunc("/text", deleteText).Methods(http.MethodDelete)
=======
	router.HandleFunc("/text/{userid}", getTexts).Methods(http.MethodGet)
	router.HandleFunc("/text", postText).Methods(http.MethodPost)
	router.HandleFunc("/text", putText).Methods(http.MethodPut)
	router.HandleFunc("/text/{textid}", deleteText).Methods(http.MethodDelete)
>>>>>>> UserAuth
	router.HandleFunc("/text", notFoundText)
}
