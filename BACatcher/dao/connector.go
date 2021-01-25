package dao

import (
	"bairescatcher/config"
	"database/sql"
	"fmt"
	_ "github.com/lib/pq"
)

var DB *sql.DB

func initConnection() {
	var psqlInfo string
	c := config.Config
	if c.Db_pwd == "" {
		psqlInfo = fmt.Sprintf("host=%s port=%d user=%s "+
			"dbname=%s sslmode=disable",
			c.Db_host, c.Db_port, c.Db_user, c.Db_name)
	} else {
		psqlInfo = fmt.Sprintf("host=%s port=%d user=%s "+
			"password=%s dbname=%s sslmode=disable",
			c.Db_host, c.Db_port, c.Db_user, c.Db_pwd, c.Db_name)
	}
	fmt.Printf("Attempting to establish connection with connection string:\n\t%s\n", psqlInfo)
	var err error
	DB, err = sql.Open("postgres", psqlInfo)
	if err != nil {
		panic(err)
	}
	err = DB.Ping()
	if err != nil {
		panic(err)
	}
	fmt.Printf("Connection established successfully!\n")
}
func Connect() {
	if DB == nil {
		initConnection()
	}
}
func Disconnect() {
	DB.Close()
}
