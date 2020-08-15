package dao

import "bairescatcher/model"

func (md *MetadataDao) Insert(p *model.Position) error {
	sqlStatement := `
INSERT INTO metadata (agency_id, route_id, id)
VALUES ($1, $2, $3)`
	_, err := DB.Exec(sqlStatement, p.Agency_id, p.Route_id, p.ID)
	return err
}
func (sd *MetadataDao) Exists(position *model.Position) (bool, error) {
	sqlStatement := `Select Exists (Select * From metadata WHERE id = $1)`
	ret := false
	err := DB.QueryRow(sqlStatement, position.ID).Scan(&ret)
	return ret, err
}

type MetadataDao struct{}

func newMetadataDao() *MetadataDao {
	return &MetadataDao{}
}
