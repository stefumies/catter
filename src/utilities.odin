package main

import "core:fmt"
import rl "vendor:raylib"

WW :: 1280
WH :: 720
FPS :: 60
BGC :: rl.Color { 110, 184, 168, 255 }
GRAVITY :: 2000
CAMERA_ZOOM :: 4
PIXEL_WINDOW_HEIGHT :: 180

get_asset :: proc(name: cstring, $T: typeid) -> T {
    assets_path := fmt.ctprintf("./assets/%s", name)
    when T == rl.Texture {
        return rl.LoadTexture(assets_path)
    }
    when T == rl.Sound {
        return rl.LoadSound(assets_path)
    }
    panic("Unsupported asset type!")
}

play_sound :: proc(s: rl.Sound) {
    rl.PlaySound(s)
}