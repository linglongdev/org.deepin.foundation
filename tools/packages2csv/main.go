package main

import (
	"bufio"
	"encoding/csv"
	"log"
	"os"

	"pault.ag/go/debian/control"
)

func main() {
	index, err := control.ParseBinaryIndex(bufio.NewReader(os.Stdin))
	if err != nil {
		log.Panic(err)
	}
	w := csv.NewWriter(os.Stdout)

	fields := index[0].Paragraph.Order
	fields = append(fields, "Source")
	w.Write(fields)
	for i := range index {
		if len(index[i].Paragraph.Values["Source"]) == 0 {
			index[i].Paragraph.Values["Source"] = index[i].Package
		}
		var val []string
		for _, filed := range fields {
			val = append(val, index[i].Paragraph.Values[filed])
		}
		w.Write(val)
	}
	w.Flush()
}
