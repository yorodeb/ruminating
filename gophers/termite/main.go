package main

import (
	"io"
	"os"
	"fmt"
	"bufio"
	"os/user"
	"strings"
)

func main() {
	reader := bufio.NewReader(os.Stdin)
	hostname, _ := os.Hostname()
	user, _ := user.Current()
	homepath := "/home/" + user.Username

	for true {
		CurrentDirectory, _ := os.Getwd()
		CurrentDirectory = strings.ReplaceAll(CurrentDirectory, homepath, "~")
		fmt.Printf("%v@%v %v$ ", user.Username, hostname, CurrentDirectory)

		input, err := reader.ReadString('\n')

		if err != nil {
			if err == io.EOF {
				break
			}
			fmt.Fprintln(os.Stdout, err)
		}

		if err := execute(input); err != nil {
			fmt.Fprintln(os.Stderr, err)
		}
	}
}
