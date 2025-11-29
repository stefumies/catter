package main

import rl "vendor:raylib"

Surface :: struct {
	name:     cstring,
	position: rl.Vector2,
	size:     rl.Vector2,
	rec:      rl.Rectangle,
	color:    rl.Color,
	texture: rl.Texture
}

surfaces: [dynamic]Surface

CreateNewSurface :: proc(x, y, width, height: f32) {
	surface := Surface {
		position = {x, y},
		size     = {width, height},
		rec      = rl.Rectangle{x, y, width, height},
		texture = get_asset("platform.png",rl.Texture)
	}
	append(&surfaces, surface)
}

DrawSurfaces :: proc() {
	for s in surfaces {
		rl.DrawTextureV(s.texture, s.position, rl.WHITE)
	}
}

InitSurfaces :: proc() {
	CreateNewSurface(-20, 20, 96,16)
	CreateNewSurface(90, -10, 96,16)
}

