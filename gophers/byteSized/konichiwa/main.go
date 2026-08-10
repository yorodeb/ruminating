package main

import (
	"fmt"
)

func main() {
	greetMsg := salutation()
	fmt.Println(greetMsg)
}

func salutation() string {
	return "Hello, World!"
}
