package main

import (
	"telemetryServer/handlers"
	"telemetryServer/helpers"

	"database/sql"
	"fmt"
	"log"
	"net/http"

	"github.com/gorilla/mux"
);

func main() {
	db, err := sql.Open("sqlite3", "./database.db")
	if err != nil{
		log.Fatal(err)
	}
	defer db.Close()

	err = helpers.SetupDatabaseSchema(db)
	if err != nil {
		log.Fatal(err)
	}

	port := 8091

	router := mux.NewRouter()

	router.HandleFunc("/sqliteQuery", func(w http.ResponseWriter, r *http.Request) {
		handlers.SqliteQuery(w, r, db)
	}).Methods("GET")
	router.HandleFunc("/test", func(w http.ResponseWriter, r *http.Request) {
		handlers.Test();
	}).Methods("POST")
	router.HandleFunc("/appendCSV", func(w http.ResponseWriter, r *http.Request) {
		handlers.AppendCSV(w, r, db)
	}).Methods("POST")

	log.Fatal(http.ListenAndServe(fmt.Sprintf(":%d", port), router))
}