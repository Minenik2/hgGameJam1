extends RigidBody3D

signal bobber_landed

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

var landed: bool = false

func initialize(initial_velocity: Vector3) -> void:
	linear_velocity = initial_velocity

func _process(delta):
	# Example: detect when bobber hits water level at y = 0
	if not landed and global_transform.origin.y <= 0.0:
		landed = true
		linear_velocity = Vector3.ZERO
		emit_signal("bobber_landed", global_transform.origin)
		
	elif landed:
		float_timer += delta
		var bob_offset = sin(float_timer * float_speed) * float_amplitude
		global_transform.origin.y = base_pos.y + bob_offset
