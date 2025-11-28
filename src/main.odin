package main

import rl "vendor:raylib"

main :: proc() {
	rl.InitWindow(WW, WH, "Cat")
	rl.SetTargetFPS(FPS)

	cat := NewPlayer(px = 640, py = 320, h = 64, w = 64)
	AddAnimationForPlayer(&cat, "cat_run", "cat_run.png", 4, 0.1)
    AddAnimationForPlayer(&cat, "cat_idle", "cat_idle.png", 2, 0.5)
	SetCurrentAnimationForPlayer(&cat, "cat_run")

	for !rl.WindowShouldClose() {
		dt := rl.GetFrameTime()
		rl.BeginDrawing()
		rl.ClearBackground(BGC)
		update(&cat, dt)
		draw(&cat)
		rl.EndDrawing()
	}
	rl.CloseWindow()
}

