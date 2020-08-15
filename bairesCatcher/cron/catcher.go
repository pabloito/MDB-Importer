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
		log.Fatalf("Error during fetch %s", err.Error())
		return
	}
	for _, v := range list {
		err = c.insertMetadata(v)
		if err != nil {
			log.Printf("Error during metadata insertion %s", err.Error())
			continue
		}
		err = c.pd.Insert(v)
		if err != nil {
			log.Printf("Error during position insertion: ID: %s t: %d, %s", v.ID, v.Timestamp, err.Error())
			continue
		}
	}
	log.Printf("Finished fetch #%d...", iteration)
}

func getPositions() ([]*model.Position, error) {
	resp, err := http.Get(config.Config.Api_uri)
	if err != nil {
		return []*model.Position{}, err
	}
	defer resp.Body.Close()
	body, err := ioutil.ReadAll(resp.Body)

	var ret []*model.Position
	err = json.Unmarshal(body, &ret)
	if err != nil {
		return []*model.Position{}, err
	}

	return ret, nil
}

func (c Catcher) insertMetadata(v *model.Position) error {
	exists, err := c.md.Exists(v)
	if err != nil {
		return err
	}
	if !exists {
		return c.md.Insert(v)
	}
	return nil

}

type Catcher struct {
	md *dao.MetadataDao
	pd *dao.PositionDao
}

func InitializeCatcher(df dao.DaoFactory) *Catcher {
	return &Catcher{df.MD, df.Pos}
}
