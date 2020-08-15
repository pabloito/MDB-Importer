package config

import (
	"bairescatcher/model"
	"encoding/json"
	"fmt"
	"os"
)

var Config = &model.Config{}

func Initialize() {
	configFile, err := os.Open("config.json")
	if err != nil {
		fmt.Printf("Error opening config file %s\n", err.Error())
		return
	}
	jsonParser := json.NewDecoder(configFile)
	if err = jsonParser.Decode(&Config); err != nil {
		fmt.Printf("Error parsing config file %s", err.Error())
	}
	fmt.Printf("Config Initialized:\n\tdb_host: %s\n\tdb_port: %d\n\tdb_user: %s\n\tdb_pwd: %s\n\tdb_name: %s\n\tapi_uri: %s\n\tinterval: %d\n\ttimes: %d\n",
		Config.Db_host, Config.Db_port, Config.Db_user, Config.Db_pwd, Config.Db_name, Config.Api_uri, Config.Interval, Config.Times)
}
