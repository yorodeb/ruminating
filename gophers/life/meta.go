package main

import raylib "github.com/gen2brain/raylib-go/raylib"
import "math/rand/v2"

var BLACK = raylib.Black
var GREEN = raylib.Green

type Meta struct {
	Width int
	Height int
	tileSize int
	State [][]int
}

func initMeta(Width int, Height int, tileSize int) *Meta {
	pluto := &Meta{Width: Width, Height: Height, tileSize: tileSize}
	
	pluto.State = initState(pluto.Width/pluto.tileSize, pluto.Height/pluto.tileSize)
	for y := range pluto.State {
		for x := range pluto.State[y] {
			pluto.State[y][x] = rand.IntN(2)
		}
	}

	return pluto
}

func initState(Width int, Height int) [][]int {
	hokeri := make([][]int, Height)
	for y := range hokeri {
		hokeri[y] = make([]int, Width)
	}

	return hokeri
}

func (M *Meta) drawMeta() {
	for y := range M.State {
		for x := 0; x < len(M.State[y]); x++ {
			if M.State[y][x] == 1 {
				pixelOfX := x * M.tileSize
				pixelOfY := y * M.tileSize

				raylib.DrawRectangle(int32(pixelOfX), int32(pixelOfY), int32(M.tileSize), int32(M.tileSize), GREEN)
			}
		}
	}

}

func (M *Meta) updateMeta() {
	newState := initState(len(M.State[0]), len(M.State))
	for idxOfY, cellOfY := range M.State {
		for idxOfX, cellOfX := range cellOfY {
			fellow := countForFellow(idxOfX, idxOfY, M.State)
			newState[idxOfY][idxOfX] = isCellAlive(cellOfX, fellow)
		}
	}

	M.State = newState
}

func countForFellow(x int, y int, State[][]int) int {
	qux := 0
	for cellOfX := x-1; cellOfX <= x+1; cellOfX++ {
		for cellOfY := y-1; cellOfY <= y+1; cellOfY++ {
			if cellOfY < 0 || cellOfX < 0 || cellOfY >= len(State) || cellOfX >= len(State[0]) {
				continue
			}

			if cellOfY == y && cellOfX == x {
				continue
			}

			if State[cellOfY][cellOfX] == 1 {
				qux++
			}

		}
	}

	return qux
}

func isCellAlive(cell int, fellow int) int {
	switch {
	case fellow < 2:
		return 0
	case fellow == 2:
		return cell
	case fellow == 3:
		return 1
	case fellow > 3:
		return 0
	}

	return 0
}
