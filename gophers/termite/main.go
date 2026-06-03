package main

import (
	"io"
	"os"
	"fmt"
	"os/user"
	"github.com/chzyer/readline"
)

func main() {
	hostname, _ := os.Hostname()

	ptrUser, _ := user.Current()
	homepath := "/home/" + ptrUser.Username

	reader, err := readline.New("")
	if err != nil {
		fmt.Fprintln(os.Stdout, err)
	}

	for {
		pluto := fmt.Sprintf("%v@%v %v$ ", ptrUser.Username, hostname, buildPromptPath(homepath))
		reader.SetPrompt(pluto)

		input, err := reader.Readline()
		if err != nil {
			if err == io.EOF {
				os.Exit(0)	
			}
			fmt.Fprintln(os.Stdout, err)
		}

		if err := execute(input); err != nil {
			fmt.Fprintln(os.Stderr, err)
		}
	}
}
