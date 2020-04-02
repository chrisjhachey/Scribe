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
	ID         int
	UserID     int
	TextID     int
	Content    string
	PageNumber string
}

// GetPassages is used to get all passages for a specific text from DB
func GetPassages(userID string, textID string) ([]byte, error) {
	var passages = []Passage{}
	db, err := sql.Open("mysql", "root:Dyonisus1!!@tcp(127.0.0.1:3306)/sys")
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
		err = results.Scan(&passage.ID, &passage.UserID, &passage.TextID, &passage.Content, &passage.PageNumber)

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
	db, err := sql.Open("mysql", "root:Dyonisus1!!@tcp(127.0.0.1:3306)/sys")
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
		err = results.Scan(&passage.ID, &passage.UserID, &passage.TextID, &passage.Content, &passage.PageNumber)

		if err != nil {
			panic(err.Error())
		}

		passages = append(passages, passage)
	}

	return json.Marshal(passages)
}

// CreatePassage is used to  create a new Passage
func CreatePassage(responseBody []byte) ([]byte, error) {
	var passages = []Passage{}
	var passage Passage
	json.Unmarshal(responseBody, &passage)

	// Opens the MYSQL database using the mysql driver along with database name and connection information
	db, err := sql.Open("mysql", "root:Dyonisus1!!@tcp(127.0.0.1:3306)/sys")
	defer db.Close()

	if err != nil {
		panic(err.Error())
	}

	// Perform a db.Query select
	insert, err := db.Prepare("INSERT INTO Passage (user_id, text_id, content, page_number) VALUES(?, ?, ?, ?)")
	defer insert.Close()

	if err != nil {
		panic(err.Error())
	}

	res, err := insert.Exec(passage.UserID, passage.TextID, passage.Content, passage.PageNumber)

	if err != nil {
		panic(err.Error())
	}

	id, _ := res.LastInsertId()

	result, err := db.Query("SELECT * FROM Passage WHERE id = ?", id)
	defer result.Close()

	for result.Next() {
		var newPassage Passage

		err = result.Scan(&newPassage.ID, &newPassage.UserID, &newPassage.TextID, &newPassage.Content, &newPassage.PageNumber)

		if err != nil {
			panic(err.Error())
		}

		passages = append(passages, newPassage)
	}

	return json.Marshal(passages)
}

// UpdatePassage is used to update a Passage
func UpdatePassage(responseBody []byte) ([]byte, error) {
	var passages = []Passage{}
	var passage Passage
	json.Unmarshal(responseBody, &passage)

	// Opens the MYSQL database using the mysql driver along with database name and connection information
	db, err := sql.Open("mysql", "root:Dyonisus1!!@tcp(127.0.0.1:3306)/sys")
	defer db.Close()

	if err != nil {
		panic(err.Error())
	}

	update, err := db.Prepare("UPDATE Passage SET Content = ?, page_number = ? WHERE ID = ?;")
	defer update.Close()

	if err != nil {
		panic(err.Error())
	}

	res, err := update.Exec(passage.Content, passage.PageNumber, passage.ID)

	if err != nil {
		panic(err.Error())
	}

	id, _ := res.LastInsertId()

	result, err := db.Query("SELECT * FROM Passage WHERE id = ?", id)
	defer result.Close()

	for result.Next() {
		var updatedPassage Passage

		err = result.Scan(&updatedPassage.ID, &updatedPassage.UserID, &updatedPassage.TextID, &updatedPassage.Content, &updatedPassage.PageNumber)

		if err != nil {
			panic(err.Error())
		}

		passages = append(passages, updatedPassage)
	}

	return json.Marshal(passages)
}
