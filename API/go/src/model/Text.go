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

// Text bject
type Text struct {
	ID       int
	UserID   int
	Name     string
	Author   string
	Passages []Passage
}

// RetrieveTexts is used to get texts
func RetrieveTexts(userID string) ([]byte, error) {
	var texts = []Text{}

	// Opens the MYSQL database using the mysql driver along with database name and connection information
	db, err := sql.Open("mysql", "root:Dyonisus1!!@tcp(127.0.0.1:3306)/Scribe")
	defer db.Close()

	if err != nil {
		panic(err.Error())
	}

	// Perform a db.Query select
	results, err := db.Query("SELECT * FROM Text WHERE user_id = ?;", userID)
	defer results.Close()

	for results.Next() {
		var text Text
		err = results.Scan(&text.ID, &text.UserID, &text.Name, &text.Author)

		if err != nil {
			panic(err.Error())
		}

		texts = append(texts, text)
	}

	return json.Marshal(texts)
}

// CreateText is used to create a new Text
func CreateText(responseBody []byte) ([]byte, error) {
	var texts = []Text{}
	var text Text
	json.Unmarshal(responseBody, &text)

	// Opens the MYSQL database using the mysql driver along with database name and connection information
	db, err := sql.Open("mysql", "root:Dyonisus1!!@tcp(127.0.0.1:3306)/Scribe")
	defer db.Close()

	if err != nil {
		panic(err.Error())
	}

	stmt, err := db.Prepare("INSERT INTO Text (user_id, name, author) VALUES(?, ?, ?)")
	defer stmt.Close()

	if err != nil {
		panic(err.Error())
	}

	res, err := stmt.Exec(text.UserID, text.Name, text.Author)

	if err != nil {
		panic(err.Error())
	}

	id, _ := res.LastInsertId()

	fmt.Println(id, "HACHEY!!!!!!!!!!")

	result, err := db.Query("SELECT * FROM Text WHERE id = ?", id)
	defer result.Close()

	for result.Next() {
		var newText Text

		err = result.Scan(&newText.ID, &newText.UserID, &newText.Name, &newText.Author)

		if err != nil {
			panic(err.Error())
		}

		texts = append(texts, newText)
	}

	return json.Marshal(texts)
}

// DeleteText is used to delete an existing Text and all it's children
func DeleteText(textID string) error {

	// Opens the MYSQL database using the mysql driver along with database name and connection information
	db, err := sql.Open("mysql", "root:Dyonisus1!!@tcp(127.0.0.1:3306)/Scribe")
	defer db.Close()

	if err != nil {
		panic(err.Error())
	}

	fmt.Println(textID)

	// Perform a db.Query select
	delete, err := db.Query("DELETE FROM Text WHERE ID = ?", textID)
	defer delete.Close()

	return err
}

// UpdateText is used to update a Text
func UpdateText(responseBody []byte) ([]byte, error) {
	var texts = []Text{}
	var text Text
	json.Unmarshal(responseBody, &text)

	// Opens the MYSQL database using the mysql driver along with database name and connection information
	db, err := sql.Open("mysql", "root:Dyonisus1!!@tcp(127.0.0.1:3306)/Scribe")
	defer db.Close()

	if err != nil {
		panic(err.Error())
	}

	update, err := db.Prepare("UPDATE Text SET Name = ?, Author = ? WHERE ID = ?;")
	defer update.Close()

	if err != nil {
		panic(err.Error())
	}

	res, err := update.Exec(text.Name, text.Author, text.ID)

	if err != nil {
		panic(err.Error())
	}

	id, _ := res.LastInsertId()

	result, err := db.Query("SELECT * FROM Text WHERE id = ?", id)
	defer result.Close()

	for result.Next() {
		var updatedText Text

		err = result.Scan(&updatedText.ID, &updatedText.UserID, &updatedText.Name, &updatedText.Author)

		if err != nil {
			panic(err.Error())
		}

		texts = append(texts, updatedText)
	}

	return json.Marshal(texts)
}
