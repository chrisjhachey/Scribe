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
)

// Passage bject
type Passage struct {
	ID      int
	TextID  int
	Content string
}

// GetPassages is used to get passages from DB
func GetPassages() ([]byte, error) {
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
	var passage Passage
	json.Unmarshal(responseBody, &passage)

	// Opens the MYSQL database using the mysql driver along with database name and connection information
	db, err := sql.Open("mysql", "root:Dyonisus1!!@tcp(127.0.0.1:3306)/Scribe")
	defer db.Close()

	if err != nil {
		panic(err.Error())
	}

	// Perform a db.Query select
	insert, err := db.Query("INSERT INTO Passage (content, text_id) VALUES(?, ?)", passage.Content, passage.TextID)
	defer insert.Close()
}
