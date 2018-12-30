package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"

	_ "github.com/lib/pq"
)

type login struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

func errorHandler(w http.ResponseWriter, message string) {
	error := struct {
		Error string `json:"error"`
	}{message}
	log.Print(message)
	response, _ := json.Marshal(error)
	w.Write(response)
}

func setHeaders(w http.ResponseWriter) {
	w.Header().Set("Content-Type", "application/json")
	w.Header().Add("Access-Control-Allow-Headers", "Content-Type")
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Access-Control-Allow-Methods", "POST, OPTIONS")
}

func loginHandler(w http.ResponseWriter, r *http.Request) {
	setHeaders(w)
	if r.Method == http.MethodOptions {
		return
	}
	if r.Method != http.MethodPost {
		errorHandler(w, "Must be POST")
		return
	}

	creds := login{}
	body, err := ioutil.ReadAll(r.Body)
	if err != nil {
		errorHandler(w, "Could not read request body")
		return
	}
	json.Unmarshal(body, &creds)

	db, err := sql.Open(
		"postgres",
		fmt.Sprintf("user=%v password=%v host=%v port=%v dbname=%v sslmode=disable",
			os.Getenv("DB_USER"),
			os.Getenv("DB_PWD"),
			os.Getenv("DB_HOST"),
			os.Getenv("DB_PORT"),
			os.Getenv("DB_NAME"),
		),
	)
	if err != nil {
		errorHandler(w, "The data source arguments are not valid")
		return
	}
	defer db.Close()
	if err := db.Ping(); err != nil {
		errorHandler(w, "Could not establish a connection with the database")
		return
	}

	var id int
	err = db.QueryRow(
		"SELECT id FROM users WHERE email=$1 and password=crypt($2, password);",
		creds.Email,
		creds.Password,
	).Scan(&id)
	if err != nil {
		fmt.Print(err)
	}
	if err == sql.ErrNoRows {
		errorHandler(w, "Invalid credentials")
		return
	}

	response, _ := json.Marshal(struct {
		UserID int `json:"user_id"`
	}{id})
	w.Write(response)
}

func main() {
	http.HandleFunc("/login", loginHandler)
	if err := http.ListenAndServe(":3001", nil); err != nil {
		panic(err)
	}
}
