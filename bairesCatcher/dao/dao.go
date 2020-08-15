package dao

type DaoFactory struct {
	MD  *MetadataDao
	Pos *PositionDao
}

func InitializeDaos() DaoFactory {
	return DaoFactory{
		MD:  newMetadataDao(),
		Pos: newPositionDao(),
	}
}
