import prepare_data
import sys
import os


def main():
    if len(sys.argv) == 6:
        path = sys.argv[1]
        host = sys.argv[2]
        port = sys.argv[3]
        username = sys.argv[4]
        dbname = sys.argv[5]

        if path[-1] == '/':
            path = path[0:-1]

        prepare_data.prepare_data(path)
        os.system(f'psql -v path=\'{path}\' -h {host} -p {port} -U {username} -d {dbname} -a -f ./load_gtfs.sql')

        if os.path.exists(path+'/calendar.txt'):
            os.system(f'psql -h {host} -p {port} -U {username} -d {dbname} -a -f ./service_dates0.sql')
        else:
            os.system(f'psql -h {host} -p {port} -U {username} -d {dbname} -a -f ./service_dates1.sql')

        os.system(f'psql -h {host} -p {port} -U {username} -d {dbname} -a -f ./load_mdb.sql')
    else:
        print("\nMust receive 5 arguments, path to gtfsdata, address, port of database, username of the database login and database name. For example: \n")
        print("./run /path/to/gtfs 0.0.0.0 25432 docker mobilitydb\n")


main()
