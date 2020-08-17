package cron

import (
	"bairescatcher/config"
	"bairescatcher/dao"
	"bairescatcher/model"
	"encoding/json"
	"io/ioutil"
	"log"
	"net/http"
	"time"
)

func (c Catcher) Fetch(interval int, times int) {
	for i := 0; i < times; i++ {
		go c.fetchAndInsert(i)
		time.Sleep(time.Duration(interval) * time.Second)
	}
}

func (c Catcher) fetchAndInsert(iteration int) {
	log.Printf("Entering fetch #%d...", iteration)
	list, err := getPositions()
	if err != nil {
		log.Printf("Error during fetch %s", err.Error())
		return
	}
	skipped := 0
	duplicates := 0
	for _, v := range list {
		if v.Vehicle.Trip.TripId == "" {
			skipped++
			continue
		}
		err = c.pd.Insert(v)
		if err != nil {
			log.Printf("Error during position insertion: ID: %s t: %d, VID: %s, %s", v.Vehicle.Trip.TripId, v.Vehicle.Timestamp, v.Vehicle.Vehicle.Id, err.Error())
			duplicates++
			continue
		}
	}
	log.Printf("Finished fetch #%d...\n\tSkipped: %d\n\tDuplicates: %d\n\tAvailable: %d\n", iteration, skipped, duplicates, len(list))
}

func getPositions() ([]*model.Entity, error) {
	resp, err := http.Get(config.Config.Api_uri)
	if err != nil {
		return []*model.Entity{}, err
	}
	defer resp.Body.Close()
	body, err := ioutil.ReadAll(resp.Body)

	var ret *model.Container
	err = json.Unmarshal(body, &ret)
	if err != nil {
		return []*model.Entity{}, err
	}

	return ret.Entities, nil
}

type Catcher struct {
	pd *dao.PositionDao
}

func InitializeCatcher(df dao.DaoFactory) *Catcher {
	return &Catcher{df.Pos}
}
