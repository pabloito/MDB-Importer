# MDB-Importer

Importing and Exporting tools for MobilityDB.

### Dependencies
MDB-Importer depends on a working PostgreSQL - PostGIS - MobilityDB installation. [Docker installation](https://docs.mobilitydb.com/MobilityDB/master/ch08.html) is recommended.  

Ensure you have installed python version 3.6+ on the host machine

```
$> python3 --version
Python 3.6.9
```

Ensure you have installed go version 1.15+ on the host machine
```
$> go version
go version go1.13.8 linux/amd64
```

### BACatcher

#### Initialization
Initialize the database by calling `BACatcher/init_script.sql`

`$> psql -h \<HOST\> -p \<PORT\> -U \<USER\> -d \<DATABASE\> -f BACatcher/init_script.sql`

The database details should be completed in the `BACatcher/config.json` file to allow correct database connection.
#### Execution
Run the following to begin polling.
```
$> go build
$> ./bairescatcher
```
#### Exporting
To export the BACatcher data execute `RealtimePipeline/BACatcherExporting/BAExporter.sql`

### GTFS Static Pipeline

Unzip GTFS data into `StaticPipeline/PreProcessing`

Execute the preprocessing in the following order.
1. `DataPruner.py`
2. `DataWrangler.go`

Move the output into `StaticPipeline/PreProcessing`

Execute the pipeline in the following order. If the calendar dates file is available replace step 2 with `DatesImporter1.sql`

1. `GTFSImporter.sql`
2. `DatesImporter0.sql`
3. `MBDBImporter.sql`

### GTFS Realtime Pipeline
Execute preprocessing pipeline
1. `RealTimePipeline/PreProcessing/CoordinateCorrector.py`

Execute data importing pipeline
1. `RealTimePipeline/DataImporting/BAImporter.sql`