package main

import "flag"
import raylib "github.com/gen2brain/raylib-go/raylib"

func main() {
	widthFlag := flag.Int("w", 800, "[ERROR]: INVALID TYPE")
	heightFlag := flag.Int("h", 400, "[ERROR]: INVALID TYPE")
	tileFlag := flag.Int("t", 10, "[ERROR]: INVALID TYPE")
	flag.Parse()

	init := initMeta(*widthFlag, *heightFlag, *tileFlag)

	raylib.InitWindow(int32(init.Width), int32(init.Height), "Conway's Game of Life")
	defer raylib.CloseWindow()

	raylib.SetTargetFPS(10)
	for !raylib.WindowShouldClose() {
		if raylib.IsKeyPressed(raylib.KeyQ) {
			break
		}
		raylib.BeginDrawing()
		raylib.ClearBackground(BLACK)

		init.updateMeta()
		init.drawMeta()
		raylib.EndDrawing()
	}
}
