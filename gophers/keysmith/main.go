package main

import (
	"fmt"
	"flag"
	"math/rand/v2"
)

func main() {
	length := flag.Int("l", 10, "[ERROR: Invalid Length]")
	flag.Parse()

	fmt.Printf("Password: %v\n", keysmith(*length))
}

func keysmith(length int) string {
	var passwd string
	for i := 0; i < length; i++ {
		qux := rand.IntN(51)
		characterOfQux := rune(qux) + 'A'
		passwd += string(characterOfQux)
	}

	return passwd
}
