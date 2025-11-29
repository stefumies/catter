package main

import rl "vendor:raylib"

Surface :: struct {
	name:     cstring,
	position: rl.Vector2,
	size:     rl.Vector2,
	rec:      rl.Rectangle,
	color:    rl.Color,
}

surfaces: map[cstring]Surface

CreateNewSurface :: proc(name: cstring, x, y, width, height: f32, color: rl.Color = rl.GREEN) {
	surface := Surface {
		name     = name,
		position = {x, y},
		size     = {width, height},
		rec      = rl.Rectangle{x, y, width, height},
		color    = color,
	}
	surfaces[name] = surface
}

GetSurface :: proc(name: cstring) -> Surface {
	surface, ok := surfaces[name]
	if !ok {
		panic("Surface not found:")
	}
	return surface
}

DrawSurfaces :: proc() {
	for n, s in surfaces {
		rl.DrawRectangleRec(s.rec, s.color)
	}
}

