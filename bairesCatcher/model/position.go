package model

type Position struct {
	Latitude  float64	`json:"_latitude"`
	Longitude float64	`json:"_longitude"`
}

type Vehicle2 struct {
	Id string `json:"_id"`
}

type Trip struct {
	StartDate string `json:"_start_date"`
	StartTime string `json:"_start_time"`
	RouteId  string `json:"_route_id"`
	TripId string `json:"_trip_id"`
	DirectionId int `json:"_direction_id"`
}

type Vehicle struct {
	Position Position `json:"_position"`
	Timestamp int64 `json:"_timestamp"`
	Trip Trip `json:"_trip"`
	Vehicle Vehicle2 `json:"_vehicle"`
}

type Entity struct {
	Vehicle Vehicle `json:"_vehicle"`
}

type Container struct {
	Entities []*Entity `json:"_entity"`
}