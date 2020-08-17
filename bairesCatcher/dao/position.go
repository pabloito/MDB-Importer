package dao

import "bairescatcher/model"

func (pd *PositionDao) Insert(p *model.Entity) error {
	sqlStatement := `INSERT INTO positions (trip_id, vehicle_id, instant, latitude, longitude, startdate, starttime, directionid)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`
	_, err := DB.Exec(sqlStatement, p.Vehicle.Trip.TripId, p.Vehicle.Vehicle.Id, p.Vehicle.Timestamp,
		p.Vehicle.Position.Latitude, p.Vehicle.Position.Longitude,p.Vehicle.Trip.StartDate,
		p.Vehicle.Trip.StartTime, p.Vehicle.Trip.DirectionId)
	return err
}

type PositionDao struct{}

func newPositionDao() *PositionDao {
	return &PositionDao{}
}
