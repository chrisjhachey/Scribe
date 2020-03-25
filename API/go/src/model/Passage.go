//
//  Text.go
//  Scribe
//
//  Created by Christopher Hachey on 2020-02-13.
//  Copyright © 2020 Christopher Hachey. All rights reserved.
//

package model

import (
	"database/sql"
	"encoding/json"
	"fmt"
)

// Passage bject
type Passage struct {
	ID      int
	UserID  int
	TextID  int
	Content string
}

// GetPassages is used to get all passages for a specific text from DB
func GetPassages(userID string, textID string) ([]byte, error) {
	var passages = []Passage{}
	db, err := sql.Open("mysql", "root:Dyonisus1!!@tcp(127.0.0.1:3306)/Scribe")
	defer db.Close()

	if err != nil {
		panic(err.Error())
	}

	results, err := db.Query("SELECT * FROM Passage WHERE user_id = ? AND text_id = ?", userID, textID)

	if err != nil {
		panic(err.Error())
	}

	for results.Next() {
		var passage Passage
		err = results.Scan(&passage.ID, &passage.UserID, &passage.TextID, &passage.Content)

		if err != nil {
			panic(err.Error())
		}

		passages = append(passages, passage)
	}

	return json.Marshal(passages)
}

// GetAllPassages is used to get all passages from DB
func GetAllPassages() ([]byte, error) {
	var passages = []Passage{}
	db, err := sql.Open("mysql", "root:Dyonisus1!!@tcp(127.0.0.1:3306)/Scribe")
	defer db.Close()

	if err != nil {
		panic(err.Error())
	}

	results, err := db.Query("SELECT * FROM Passage;")

	if err != nil {
		panic(err.Error())
	}

	for results.Next() {
		var passage Passage
		err = results.Scan(&passage.ID, &passage.Content, &passage.TextID)

		if err != nil {
			panic(err.Error())
		}

		passages = append(passages, passage)
	}

	return json.Marshal(passages)
}

// CreatePassage is used to  create a new Passage
func CreatePassage(responseBody []byte) {
	fmt.Println("Made it into create passage")
	var passage Passage
	json.Unmarshal(responseBody, &passage)

	// Opens the MYSQL database using the mysql driver along with database name and connection information
	db, err := sql.Open("mysql", "root:Dyonisus1!!@tcp(127.0.0.1:3306)/Scribe")
	defer db.Close()

	if err != nil {
		panic(err.Error())
	}

	fmt.Println("Made it to this part of Create Passage")
	fmt.Println("Passage Content: ", passage.Content, " Text ID: ", passage.TextID)

	// Perform a db.Query select
	insert, err := db.Query("INSERT INTO Passage (user_id, text_id, content) VALUES(?, ?, ?)", passage.UserID, passage.TextID, passage.Content)
	defer insert.Close()

	if err != nil {
		fmt.Println(err.Error())
	}
}
