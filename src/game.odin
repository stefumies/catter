package main

import rl "vendor:raylib"


draw :: proc(p: ^Player) {
	DrawPlayer(p)
}

update :: proc(p: ^Player, dt: f32) {
	UpdatePlayer(p, dt)
}

