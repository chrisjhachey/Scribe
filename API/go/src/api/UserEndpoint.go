package api

import (
	"fmt"
	"io/ioutil"
	"model"
	"net/http"

	"github.com/gorilla/mux"
)

func getUsers(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	w.Write([]byte(`{"message": "get called on user"}`))
}

func postUser(w http.ResponseWriter, r *http.Request) {
	bytes, err := ioutil.ReadAll(r.Body)

	if err != nil {
		panic(err.Error())
	}

	theUser, err := model.CreateUser(bytes)

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	w.Write([]byte(string(theUser)))
	//w.Write([]byte(`{"message": "Post Called Successfully"}`))

	fmt.Println(string(theUser))
}

func putUser(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusAccepted)
	w.Write([]byte(`{"message": "put called on user"}`))
}

func deleteUser(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(204)
	w.Write([]byte(`{"message": "delete called on user"}`))
}

func notFoundUser(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusNotFound)
	w.Write([]byte(`{"message": "not found for user"}`))
}

// SetUserHandlerFunctions sets the handler functions for the Router and adds a matcher for the HTTP verb
func SetUserHandlerFunctions(router *mux.Router) {
	router.HandleFunc("/user", getUsers).Methods(http.MethodGet)
	router.HandleFunc("/user", postUser).Methods(http.MethodPost)
	router.HandleFunc("/user", deleteUser).Methods(http.MethodDelete)
	router.HandleFunc("/user", notFoundUser)
}
