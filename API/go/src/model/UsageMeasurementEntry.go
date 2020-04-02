package model

import (
	"database/sql"
	"encoding/json"
	"fmt"
)

// UsageMeasurementEntry object
type UsageMeasurementEntry struct {
	ID        int
	UserID    int
	Action    string
	DateStamp string
}

// CreateUsageEntry is used to create a new Text
func CreateUsageEntry(responseBody []byte) ([]byte, error) {
	var usageEntries = []UsageMeasurementEntry{}
	var usageEntry UsageMeasurementEntry
	json.Unmarshal(responseBody, &usageEntry)

	// Opens the MYSQL database in Amazon RDS using the mysql driver along with database name and connection information
	db, err := sql.Open("mysql", "admin:Dyonisus1!!@tcp(scribedatabase-1.ctsuni8djs5u.us-east-2.rds.amazonaws.com)/innodb")
	defer db.Close()

	if err != nil {
		panic(err.Error())
	}

	stmt, err := db.Prepare("INSERT INTO UsageMeasurementEntry (user_id, action, date_stamp) VALUES(?, ?, ?)")
	defer stmt.Close()

	if err != nil {
		panic(err.Error())
	}

	res, err := stmt.Exec(usageEntry.UserID, usageEntry.Action, usageEntry.DateStamp)

	if err != nil {
		panic(err.Error())
	}

	id, _ := res.LastInsertId()

	fmt.Println(id, "HACHEY!!!!!!!!!!")

	result, err := db.Query("SELECT * FROM UsageMeasurementEntry WHERE id = ?", id)
	defer result.Close()

	for result.Next() {
		var newUsageEntry UsageMeasurementEntry

		err = result.Scan(&newUsageEntry.ID, &newUsageEntry.UserID, &newUsageEntry.Action, &newUsageEntry.DateStamp)

		if err != nil {
			panic(err.Error())
		}

		usageEntries = append(usageEntries, newUsageEntry)
	}

	return json.Marshal(usageEntries)
}
