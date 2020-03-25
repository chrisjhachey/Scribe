package api

import (
	"io/ioutil"
	"model"
	"net/http"
	"time"

	"github.com/dgrijalva/jwt-go"
	"github.com/gorilla/mux"
)

func getRefreshToken(w http.ResponseWriter, r *http.Request) {
	//w.Write([]byte(`"message": "Refresh endpoint hit!"`))

	bytes, err := ioutil.ReadAll(r.Body)

	if err != nil {
		panic(err.Error())
	}

	theToken, err := model.CreateTokenFromJSON(bytes)

	if err != nil {
		panic(err.Error())
	}

	tokenString := theToken.Token
	claims := &model.Claims{}
	tkn, err := jwt.ParseWithClaims(tokenString, claims, func(token *jwt.Token) (interface{}, error) {
		return model.JWTKey, nil
	})

	if err != nil {
		if err == jwt.ErrSignatureInvalid {
			w.WriteHeader(http.StatusUnauthorized)
			return
		}
		w.WriteHeader(http.StatusBadRequest)
		return
	}
	if !tkn.Valid {
		w.WriteHeader(http.StatusUnauthorized)
		return
	}

	// We ensure that a new token is not issued until enough time has elapsed
	// In this case, a new token will only be issued if the old token is within
	// 30 seconds of expiry. Otherwise, return a bad request status
	if time.Unix(claims.ExpiresAt, 0).Sub(time.Now()) > 30*time.Second {
		w.WriteHeader(http.StatusBadRequest)
		return
	}

	// Now, create a new token for the current use, with a renewed expiration time
	expirationTime := time.Now().Add(5 * time.Minute)
	claims.ExpiresAt = expirationTime.Unix()
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tknStr, err := token.SignedString(model.JWTKey)

	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	t, err := model.CreateToken(tknStr, expirationTime)

	w.WriteHeader(http.StatusOK)
	w.Write([]byte(string(t)))
}

// SetRefreshHandlerFunctions sets the handler functions for the Router and adds a matcher for the HTTP verb
func SetRefreshHandlerFunctions(router *mux.Router) {
	router.HandleFunc("/refresh", getRefreshToken).Methods(http.MethodPost)
}
