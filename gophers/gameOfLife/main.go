package main

import raylib "github.com/gen2brain/raylib-go/raylib"

func main() {
	init := initMeta(800, 400, 10)

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
