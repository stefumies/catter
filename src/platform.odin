package main

import rl "vendor:raylib"

Surface :: struct {
	name:     cstring,
	position: rl.Vector2,
	size:     rl.Vector2,
	rec:      rl.Rectangle,
}

NewSurface :: proc(name: cstring, x, y, width, height: f32) -> Surface {
	return Surface {
		name = name,
		position = {x, y},
		size = {width, height},
		rec = rl.Rectangle{x, y, width, height},
	}
}

DrawSurface :: proc() {
	platform := rl.Rectangle{-20, 20, 96, 16}
	rl.DrawRectangleRec(platform, rl.RED)
}

