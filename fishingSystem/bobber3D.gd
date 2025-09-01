extends Node3D

signal landed_on_water
signal bite_started

@export var water_level := 0.0
@export var gravity := 9.8 * 20
@export var float_amplitude := 0.2
@export var float_speed := 2.0
@export var catch_window := 0.8

var velocity := Vector3.ZERO
var floating := false
var float_timer := 0.0
var base_pos := Vector3.ZERO
var fish_on_line := false
var minigame_active := false

func _process(delta):
	if not floating:
		velocity.y -= gravity * delta
		global_translate(velocity * delta)
		if global_transform.origin.y <= water_level:
			global_transform.origin.y = water_level
			velocity = Vector3.ZERO
			floating = true
			base_pos = global_transform.origin
			emit_signal("landed_on_water")
	else:
		float_timer += delta
		var bob_offset = sin(float_timer * float_speed) * float_amplitude
		global_transform.origin.y = base_pos.y + bob_offset
