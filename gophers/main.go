package main

import (
	"fmt"
	"flag"
)

func main() {
	pluto := flag.Int("t", 10, "Invalid")
	flag.Parse()
	fmt.Println(*pluto)
}
