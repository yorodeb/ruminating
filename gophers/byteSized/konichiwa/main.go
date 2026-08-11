package main

import (
	"fmt"
)

func main() {
	prgOut := greet()
	fmt.Println(prgOut)
}

func greet() string {
	return "Hello, World!"
}
