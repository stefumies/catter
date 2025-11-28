package main

import fmt "core:fmt"
import rl "vendor:raylib"

PH :: 64
PW :: 64
PCLR :: rl.GREEN
PSPEED :: 400
PJSPEED :: 800
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
	UP,
	DOWN,
}

PlayerState :: struct {
	is_grounded: bool,
	orientation: PlayerOrientation,
}

Player :: struct {
	position:        rl.Vector2,
	velocity:        rl.Vector2,
	size:            rl.Vector2,
	color:           rl.Color,
	using state:     PlayerState,
	using animation: PlayerAnimation,
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
		width  = ca.frame_length * P_SCALE,
		height = f32(ca.texture.height * P_SCALE),
	}

	rl.DrawTexturePro(ca.texture, src_rec, dest_rec, {0, 0}, 0, rl.WHITE)

}

NewPlayer :: proc(
	px: f32,
	py: f32,
	h: f32 = PH,
	w: f32 = PH,
	vx: f32 = 0,
	vy: f32 = 0,
	color: rl.Color = PCLR,
) -> Player {
	return Player {
		position = rl.Vector2{px, py},
		velocity = rl.Vector2{vx, vy},
		size = rl.Vector2{w, h},
		color = color,
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

IsPlayerGrounded :: proc(p: Player) -> bool {
	return p.position.y > f32(rl.GetScreenHeight()) - p.size.y
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
		p.orientation = .UP
		p.velocity.y = -PJSPEED
		p.is_grounded = false
	}

	p.position += p.velocity * dt
	if IsPlayerGrounded(p^) {
		p.position.y = get_abs_floor_for_player(p^)
		p.is_grounded = true
	}

	PlayerDrawAnimationUpdateState(p)

}

DrawPlayer :: proc(p: ^Player) {
	PlayerDrawAnimate(p)
}

