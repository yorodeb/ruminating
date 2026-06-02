package main

import (
	"os"
	"os/exec"
	"strings"
)

func execute(argv string) error {
	args := strings.Fields(argv)
	if len(args) == 0 {
		return nil
	}

	switch args[0] {
	case "cd":
		if len(args) < 2 {
			home, err := os.UserHomeDir()
			if err != nil {
				return err
			}
			return os.Chdir(home)
		}
		return os.Chdir(args[1])
	}

	command := exec.Command(args[0], args[1:]...)
	command.Stderr = os.Stderr
	command.Stdout = os.Stdout

	return command.Run()
}

func buildPromptPath(homepath string) string {
	current, _ := os.Getwd()
	return strings.ReplaceAll(current, homepath, "~")
}
