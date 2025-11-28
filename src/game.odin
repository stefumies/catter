package main

import rl "vendor:raylib"

draw :: proc(p: ^Player) {
	DrawPlayer(p)
}

update :: proc(p: ^Player, dt: f32) {
	UpdatePlayer(p, dt)
}
get_game_camera :: proc(p: Player, offset: rl.Vector2, relative_zoom: f32) -> rl.Camera2D {
    return  rl.Camera2D {
        zoom   = relative_zoom/PIXEL_WINDOW_HEIGHT,
        offset = offset,
        target = p.position
    }
}
