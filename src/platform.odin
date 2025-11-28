package main

import rl "vendor:raylib"

get_abs_floor_for_player :: proc(p: Player) -> f32 {
	return f32(rl.GetScreenHeight()) - p.size.y
}

