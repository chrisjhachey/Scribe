package model

import (
	"encoding/json"
	"net/http"
	"time"

	"github.com/dgrijalva/jwt-go"
)

// JWTKey is the secret
var JWTKey = []byte("aeschylus_sophocles_euripides")

// Token represents an authorization token
type Token struct {
	ID      int
	Token   string
	Expirey time.Time
	Valid   bool
}

// Claims is a struct that will be encoded to a JWT.
// We add jwt.StandardClaims as an embedded type, to provide fields like expiry time
type Claims struct {
	Username string `json:"username"`
	jwt.StandardClaims
}

// CreateToken creates a token model
func CreateToken(theToken string, theExpirey time.Time) ([]byte, error) {
	var tokens = []Token{}

	t := Token{
		ID:      0,
		Token:   theToken,
		Expirey: theExpirey,
		Valid:   true,
	}

	tokens = append(tokens, t)

	return json.Marshal(tokens)
}

// CreateTokenFromJSON creates a Token object from JSON
func CreateTokenFromJSON(responseBody []byte) (Token, error) {
	var token Token
	err := json.Unmarshal(responseBody, &token)

	return token, err
}

// ValidateToken checks the local chache for the existence of the token
func ValidateToken(r *http.Request) bool {
	token := r.Header.Get("Scribe-Token")
	// Initialize a new instance of `Claims`
	claims := &Claims{}

	// Parse the JWT string and store the result in `claims`.
	// Note that we are passing the key in this method as well. This method will return an error
	// if the token is invalid (if it has expired according to the expiry time we set on sign in),
	// or if the signature does not match
	tkn, err := jwt.ParseWithClaims(token, claims, func(token *jwt.Token) (interface{}, error) {
		return JWTKey, nil
	})
	if err != nil {
		return false
	}

	if !tkn.Valid {
		return false
	}

	return true
}
