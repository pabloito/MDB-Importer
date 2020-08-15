package dao

import "bairescatcher/model"

func (pd *PositionDao) Insert(p *model.Position) error {
	sqlStatement := `INSERT INTO positions (id, instant, latitude, longitude)
VALUES ($1, $2, $3, $4)`
	_, err := DB.Exec(sqlStatement, p.ID, p.Timestamp, p.Latitude, p.Longitude)
	return err
}

type PositionDao struct{}

func newPositionDao() *PositionDao {
	return &PositionDao{}
}
