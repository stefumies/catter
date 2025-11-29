package main

import fmt "core:fmt"
import rl "vendor:raylib"

PH :: 64
PW :: 64
PCLR :: rl.GREEN
PSPEED :: 100
PJSPEED :: 550
P_SCALE :: 4

PlayerAnimationSprite :: struct {
	texture:      rl.Texture,
	total_frames: i32,
	frame_length: f32,
	is_flipped:   bool,
}

PlayerAnimation :: struct {
	animations:             map[cstring]PlayerAnimationSprite,
	current_animation:      PlayerAnimationSprite,
	animation_frame_timer:  f32,
	animation_frame_length: f32,
	current_frame:          int,
}

PlayerOrientation :: enum {
	LEFT,
	RIGHT,
}

PlayerState :: struct {
	is_grounded: bool,
	orientation: PlayerOrientation,
}


PlayerCollisionZoneDirection :: enum {
	TOP,
	BOTTOM,
	FRONT,
}

PlayerCollisionZone :: struct {
	direction: PlayerCollisionZoneDirection,
	cz_rec:    rl.Rectangle,
	color:     rl.Color,
}

Player :: struct {
	position:        rl.Vector2,
	velocity:        rl.Vector2,
	size:            rl.Vector2,
	color:           rl.Color,
	collisonZones:   map[PlayerCollisionZoneDirection]PlayerCollisionZone,
	using state:     PlayerState,
	using animation: PlayerAnimation,
}

PlayerCollidesWithurfaces :: proc(p: ^Player) {
	for direction, zone in p.collisonZones {
		for surface in surfaces {
			if rl.CheckCollisionRecs(zone.cz_rec, surface.rec) {
				switch direction {
				case .TOP:
					if p.velocity.y < 0 {
						p.velocity.y = 0
						p.position.y = surface.rec.y + surface.rec.height
						p.is_grounded = false
					}
				case .BOTTOM:
					if rl.CheckCollisionRecs(zone.cz_rec, surface.rec) && p.velocity.y > 0 {
						p.velocity.y = 0
						p.position.y = surface.rec.y
						p.is_grounded = true
					}
				case .FRONT:
					if p.velocity.x < 0 {
						p.velocity.x = 0
						p.position.x = surface.rec.x + surface.rec.width
					}
				}
			}
		}
	}
}

PlayerDrawAnimationUpdateState :: proc(p: ^Player) {
	p.animation_frame_length = 0.1
	p.animation_frame_timer += rl.GetFrameTime()
	if p.animation_frame_timer > p.animation_frame_length {
		p.current_frame += 1
		p.animation_frame_timer = 0
		if i32(p.current_frame) == p.current_animation.total_frames {
			p.current_frame = 0
		}
	}
}

CreatePlayerCollisionZone :: proc(
	x, y, w, h: f32,
	d: PlayerCollisionZoneDirection,
	cl: rl.Color = rl.Color{0, 255, 0, 100},
) -> PlayerCollisionZone {
	return {d, rl.Rectangle{x, y, w, h}, cl}
}

PlayerDrawAnimate :: proc(p: ^Player) {
	ca := p.current_animation

	src_rec := rl.Rectangle {
		x      = f32(p.current_frame) * ca.frame_length,
		y      = 0,
		width  = ca.frame_length,
		height = f32(ca.texture.height),
	}

	if ca.is_flipped {
		src_rec.width = -src_rec.width
	}

	dest_rec := rl.Rectangle {
		x      = p.position.x,
		y      = p.position.y,
		width  = ca.frame_length,
		height = f32(ca.texture.height),
	}

	p.collisonZones[.BOTTOM] = CreatePlayerCollisionZone(
		p.position.x - P_SCALE,
		p.position.y - P_SCALE,
		P_SCALE * 2,
		P_SCALE,
		.BOTTOM,
	)

	collision_zone_top_x := p.position.x - P_SCALE - 2
	if p.current_animation.is_flipped == false {
		collision_zone_top_x = p.position.x + P_SCALE -14
	}

	p.collisonZones[.TOP] = CreatePlayerCollisionZone(
		collision_zone_top_x,
		p.position.y - P_SCALE * P_SCALE + 1.2,
		P_SCALE * 4,
		P_SCALE / 2,
		.TOP,
	)


	collision_zone_x := p.position.x - P_SCALE - 2.92

	if p.current_animation.is_flipped == false {
		collision_zone_x = p.position.x + P_SCALE + 1.2
	}

	p.collisonZones[.FRONT] = CreatePlayerCollisionZone(
		collision_zone_x,
		p.position.y - P_SCALE * 3.5,
		2,
		8,
		.FRONT,
		rl.Color{255, 100, 0, 100},
	)


	p_origin_at_feet := rl.Vector2{dest_rec.width / 2, dest_rec.height}
	rl.DrawTexturePro(ca.texture, src_rec, dest_rec, p_origin_at_feet, 0, rl.WHITE)
	// Remove if no longer debugging
	for direction, zone in p.collisonZones {
		rl.DrawRectangleRec(zone.cz_rec, zone.color)
	}
}

NewPlayer :: proc(px: f32, py: f32, h: f32 = PH, w: f32 = PH, vx: f32 = 0, vy: f32 = 0) -> Player {
	return Player {
		position = rl.Vector2{px, py},
		velocity = rl.Vector2{vx, vy},
		size = rl.Vector2{w, h},
	}
}

AddAnimationForPlayer :: proc(
	p: ^Player,
	animation_name, sprite_name: cstring,
	total_frames: i32 = 1,
	animation_frame_length: f32 = 0.1,
) {
	if p.animations == nil {
		p.animations = make(map[cstring]PlayerAnimationSprite)
	}
	texture := get_asset(sprite_name, rl.Texture)
	frame_length := f32(texture.width) / f32(total_frames)
	p.animations[animation_name] = PlayerAnimationSprite {
		texture      = texture,
		total_frames = total_frames,
		frame_length = frame_length,
	}
	p.animation_frame_length = animation_frame_length
}

SetCurrentAnimationForPlayer :: proc(p: ^Player, animation_name: cstring) {
	animation, is_found := p.animations[animation_name]
	if is_found == false {
		fmt.panicf("No such animation: %s", animation_name)
	}
	p.current_animation = animation
}

UpdatePlayer :: proc(p: ^Player, dt: f32) {

	p.velocity.y += GRAVITY * dt

	if rl.IsKeyDown(.LEFT) {
		p.orientation = .LEFT
		p.velocity.x = -PSPEED
		SetCurrentAnimationForPlayer(p, "cat_run")
		p.current_animation.is_flipped = true
	} else if rl.IsKeyDown(.RIGHT) {
		p.orientation = .RIGHT
		p.velocity.x = PSPEED
		SetCurrentAnimationForPlayer(p, "cat_run")
		p.current_animation.is_flipped = false
	} else {
		p.velocity.x = 0
		SetCurrentAnimationForPlayer(p, "cat_idle")
		p.current_animation.is_flipped = p.orientation == .LEFT
	}

	if p.is_grounded && rl.IsKeyDown(.SPACE) {
		p.velocity.y = -PJSPEED
	}

	p.is_grounded = false
	p.position += p.velocity * dt

	PlayerCollidesWithurfaces(p)
	PlayerDrawAnimationUpdateState(p)
}

DrawPlayer :: proc(p: ^Player) {
	PlayerDrawAnimate(p)
}

InitAnimatons :: proc(p:^Player){
	AddAnimationForPlayer(p, "cat_run", "cat_run.png", 4, 0.1)
	AddAnimationForPlayer(p, "cat_idle", "cat_idle.png", 2, 0.5)
	SetCurrentAnimationForPlayer(p, "cat_run")
}