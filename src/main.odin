package main

import rl "vendor:raylib"

main :: proc() {
	rl.InitWindow(WW, WH, "Cat")
	rl.SetTargetFPS(FPS)
	rl.SetWindowState({.WINDOW_RESIZABLE})

	cat := NewPlayer(px = 0, py = 0, h = 64, w = 64)
	InitGame(&cat)

	for !rl.WindowShouldClose() {
		dt := rl.GetFrameTime()
		rl.BeginDrawing()
		rl.ClearBackground(BGC)
		camera := get_game_camera(cat)
		rl.BeginMode2D(camera)
		update(&cat, dt)
		draw(&cat)
		rl.EndMode2D()
		rl.EndDrawing()
	}
	rl.CloseWindow()
}

