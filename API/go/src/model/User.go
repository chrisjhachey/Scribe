package model

import (
	"database/sql"
	"encoding/json"
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

	// Opens the MYSQL database in Amazon RDS using the mysql driver along with database name and connection information
	db, err := sql.Open("mysql", "admin:Dyonisus1!!@tcp(scribedatabase-1.ctsuni8djs5u.us-east-2.rds.amazonaws.com)/innodb")
	defer db.Close()

	// awsCreds := credentials.NewEnvCredentials()

	// dbEndpoint := "scribedatabase-1.ctsuni8djs5u.us-east-2.rds.amazonaws.com"
	// awsRegion := "us-east-2b"

	// //creating authentication token for the database connection
	// authToken, err := rdsutils.BuildAuthToken(dbEndpoint, awsRegion, "admin:Dyonisus1!!", awsCreds)

	// if err != nil {
	// 	//log.Fatal("Unable to build Authentication Token") //todo remove
	// 	fmt.Println("You didn't connect to the RDS bescause: ", err.Error())
	// } else {
	// 	fmt.Println("Auth Token: ", authToken)
	// }

	// //setting up TLS
	// mysql.RegisterTLSConfig("custom", &tls.Config{
	// 	InsecureSkipVerify: true,
	// })

	// // Create the MySQL DNS string for the DB connection
	// // user:password@protocol(endpoint)/dbname?<params>
	// connectStr := fmt.Sprintf("%s:%s@tcp(%s)/%s?allowCleartextPasswords=true&tls=custom", "admin", authToken, dbEndpoint, "scribedatabase-1")

	// // Use db to perform SQL operations on database
	// db, err := sql.Open("mysql", connectStr)
	// defer db.Close()

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

	// Opens the MYSQL database in Amazon RDS using the mysql driver along with database name and connection information
	db, err := sql.Open("mysql", "admin:Dyonisus1!!@tcp(scribedatabase-1.ctsuni8djs5u.us-east-2.rds.amazonaws.com)/innodb")
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
