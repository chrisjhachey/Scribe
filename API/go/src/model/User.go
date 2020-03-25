package model

import (
	"database/sql"
	"encoding/json"
	"fmt"
)

// User represents a Scribe User
type User struct {
	ID       int
	Username string
	Password string
}

// CreateUser creates a new user and inserts it into the database
func CreateUser(responseBody []byte) ([]byte, error) {
	var users = []User{}
	var user User
	json.Unmarshal(responseBody, &user)

	// Opens the MYSQL database using the mysql driver along with database name and connection information
	db, err := sql.Open("mysql", "root:Dyonisus1!!@tcp(127.0.0.1:3306)/Scribe")
	defer db.Close()

	if err != nil {
		panic(err.Error())
	}

	stmt, err := db.Prepare("INSERT INTO User (username, password) VALUES(?, ?)")
	defer stmt.Close()

	if err != nil {
		panic(err.Error())
	}

	res, err := stmt.Exec(user.Username, user.Password)

	if err != nil {
		panic(err.Error())
	}

	id, _ := res.LastInsertId()

	fmt.Println(id, "HACHEY!!!!!!!!!!")

	result, err := db.Query("SELECT * FROM User WHERE id = ?", id)
	defer result.Close()

	for result.Next() {
		var newUser User

		err = result.Scan(&newUser.ID, &newUser.Username, &newUser.Password)

		if err != nil {
			panic(err.Error())
		}

		users = append(users, newUser)
	}

	return json.Marshal(users)
}

// CheckCredentials checks to see if the username and password are correct
func CheckCredentials(username string, password string) (int, bool) {

	// Opens the MYSQL database using the mysql driver along with database name and connection information
	db, err := sql.Open("mysql", "root:Dyonisus1!!@tcp(127.0.0.1:3306)/Scribe")
	defer db.Close()

	if err != nil {
		panic(err.Error())
	}

	// Perform a db.Query select
	result := db.QueryRow("SELECT * FROM User WHERE username = ? AND password = ?;", username, password)

	u := User{}
	isNil := result.Scan(&u.ID, &u.Username, &u.Password)

	if isNil != nil {
		return 0, false
	}

	return u.ID, true
}
