package main

import (
    "encoding/csv"
    "fmt"
    "io"
    "os"
    "strconv"
    "strings"
)

func main() {
    args := os.Args
    if len(args) != 2 {
        fmt.Printf("Must receive 1 argument, path to gtfsdata. For example: \n")
        fmt.Printf("./stop_times ../path/to/gtfs\n")
        os.Exit(-1)
    }
    orPath, prPath := os.Args[1]+"/stop_times.txt", os.Args[1]+"stop_times_processed.txt"
    read, err := os.Open(orPath)
    write, err := os.Create(prPath)
    if err != nil {
        fmt.Printf("error %s", err.Error())
        os.Exit(1)
    }
    //trip_id,arrival_time,departure_time,stop_id,stop_sequence
    r := csv.NewReader(read)
    w := csv.NewWriter(write)

    defer w.Flush()

    header, _ := r.Read()
    _ = w.Write(header)

    lastRow, _ := r.Read()
    _ = w.Write(lastRow)

    processedRows, culprits := 0, 0

    prevTrip := lastRow[0]
    prevTime, err := newTime(lastRow[2])
    if err != nil {
        fmt.Printf("error %s",err.Error())
    }
    for {
        row, err := r.Read()
        if err == io.EOF{
            break
        }
        if err != nil {
            fmt.Printf("error %s", err.Error())
            os.Exit(1)
        }
        trip := row[0]
        arrival, _ := newTime(row[1])
        departure, _ := newTime(row[2])
        if trip == prevTrip && arrival.compare(prevTime) <= 0 {
            arrival.set(prevTime)
            arrival.increase()
            row[1] = arrival.toString()

            if departure.compare(arrival) < 0 {
                departure.set(arrival)
                row[2] = departure.toString()
            }
            culprits += 1 //keep track of broken records
        }
        _ = w.Write(row)
        prevTime = departure
        prevTrip = trip
        processedRows += 1
        if processedRows % 10000 == 0 {
            fmt.Printf("Processed %d rows, found %d culprits\n",processedRows, culprits)
        }
    }
    fmt.Printf("done processed %d rows\ntotal culprits %d\n", processedRows, culprits)
    os.Remove(orPath)
    os.Rename(prPath,orPath)
}

type Time struct {
    h,m,s int
}
func (t *Time) set(t1 *Time) {
    t.s =t1.s
    t.m =t1.m
    t.h =t1.h
}
func (t *Time) increase() {
    t.s += 1
    if t.s < 60 {
        return
    }
    t.s = 0
    t.m += 1
    if t.m < 60 {
        return
    }
    t.m = 0
    t.h += 1
}

func (t *Time) compare(t1 *Time) int {
    return 3600*(t.h-t1.h) + 60*(t.m-t1.m) + (t.s-t1.s)
}

func (t *Time) toString() string {
    return fmt.Sprintf("%02d:%02d:%02d", t.h, t.m, t.s)
}

func newTime(s string) (*Time, error) {
    split := strings.Split(s, ":")
    h, err := strconv.Atoi(split[0])
    if err != nil {
        return nil, err
    }
    m, err := strconv.Atoi(split[1])
    if err != nil {
        return nil, err
    }
    sec, err := strconv.Atoi(split[2])
    if err != nil {
        return nil, err
    }
    return &Time{
        h: h,
        m: m,
        s: sec,
    }, nil
}
