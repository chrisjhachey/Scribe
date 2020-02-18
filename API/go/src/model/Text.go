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

// Text bject
type Text struct {
	ID       int
	Name     string
	Author   string
	Passages []Passage
}

// RetrieveTexts is used to get texts
func RetrieveTexts() ([]byte, error) {
	var texts = []Text{}

	// Opens the MYSQL database using the mysql driver along with database name and connection information
	db, err := sql.Open("mysql", "root:Dyonisus1!!@tcp(127.0.0.1:3306)/Scribe")
	defer db.Close()

	if err != nil {
		panic(err.Error())
	}

	// Perform a db.Query select
	results, err := db.Query("SELECT * FROM Text;")
	defer results.Close()

	for results.Next() {
		var text Text
		err = results.Scan(&text.ID, &text.Name, &text.Author)

		if err != nil {
			panic(err.Error())
		}

		texts = append(texts, text)
	}

	return json.Marshal(texts)
}

// CreateText is used to  create a new Text
func CreateText(responseBody []byte) {
	var text Text
	json.Unmarshal(responseBody, &text)

	// Opens the MYSQL database using the mysql driver along with database name and connection information
	db, err := sql.Open("mysql", "root:Dyonisus1!!@tcp(127.0.0.1:3306)/Scribe")
	defer db.Close()

	if err != nil {
		panic(err.Error())
	}

	// Perform a db.Query select
	insert, err := db.Query("INSERT INTO Text (name, author) VALUES(?, ?)", text.Name, text.Author)
	defer insert.Close()
}
