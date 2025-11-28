package main

import rl "vendor:raylib"

draw :: proc(p: ^Player) {
	DrawPlayer(p)
}

update :: proc(p: ^Player, dt: f32) {
	UpdatePlayer(p, dt)
}
get_game_camera :: proc(p: Player) -> rl.Camera2D {
    os := rl.Vector2{f32(rl.GetScreenWidth()/2), f32(rl.GetScreenHeight() / 2)}
    return  rl.Camera2D {
        zoom   = f32(rl.GetScreenHeight())/PIXEL_WINDOW_HEIGHT,
        offset = os,
        target = p.position
    }
}
