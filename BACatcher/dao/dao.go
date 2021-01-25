package dao

type DaoFactory struct {
	Pos *PositionDao
}

func InitializeDaos() DaoFactory {
	return DaoFactory{
		Pos: newPositionDao(),
	}
}
