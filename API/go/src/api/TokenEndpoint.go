// the format is HEADER(base64 encoded).PAYLOAD(base64 encoded).SIGNITURE(Hash*(HEADER + PAYLOAD))
// the HEADER typically contains th type: JWT, and the Hashing alg: HMAC
// the PAYLOAD contains some combinations of registered, public and private claims: {exp: 28282888, iss: "Scribe", name: chris h}
// the SIGNITURE is a concatenation of the base64 encoded HEADER + "." + PAYLOAD hased with an API SECRET. Provider keeps the SECREY safe.

package api

import (
	"model"
	"net/http"
	"strconv"
	"time"

	"github.com/dgrijalva/jwt-go"
	"github.com/gorilla/mux"
)

func getToken(w http.ResponseWriter, r *http.Request) {
	keys := r.URL.Query()

	username := keys["username"]
	password := keys["password"]

	if username == nil || password == nil {
		panic("URL param is missing!")
	}

	userID, validCredentials := model.CheckCredentials(username[0], password[0])

	w.Header().Set("Content-Type", "application/json")

	if !validCredentials {
		w.WriteHeader(http.StatusUnauthorized)
		w.Write([]byte(`{"message": "Login credentials are invalid!"}`))
	} else {
		expirationTime := time.Now().Add(5 * time.Minute)
		// Create the JWT claims, which includes the username and expiry time
		claims := &model.Claims{
			Username: username[0],
			StandardClaims: jwt.StandardClaims{
				// In JWT, the expiry time is expressed as unix milliseconds
				ExpiresAt: expirationTime.Unix(),
			},
		}

		// Declare the token with the algorithm used for signing, and the claims
		token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
		// Create the JWT string
		tokenString, err := token.SignedString(model.JWTKey)

		if err != nil {
			// If there is an error in creating the JWT return an internal server error
			w.WriteHeader(http.StatusInternalServerError)
			return
		}

		t, err := model.CreateToken(tokenString, expirationTime)

		w.Header().Add("UserID", strconv.Itoa(userID))
		w.WriteHeader(http.StatusOK)
		w.Write([]byte(string(t)))
	}
}

// SetTokenHandlerFunctions sets the handler functions for the Router and adds a matcher for the HTTP verb
func SetTokenHandlerFunctions(router *mux.Router) {
	router.HandleFunc("/token", getToken).Methods(http.MethodGet)
}
