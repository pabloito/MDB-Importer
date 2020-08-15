package main

import (
	"bairescatcher/config"
	"bairescatcher/cron"
	"bairescatcher/dao"
)

func main() {
	config.Initialize()
	dao.Connect()
	df := dao.InitializeDaos()
	catcher := cron.InitializeCatcher(df)
	catcher.Fetch(config.Config.Interval, config.Config.Times)
	dao.Disconnect()
}
