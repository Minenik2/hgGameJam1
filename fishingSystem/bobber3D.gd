extends RigidBody3D

signal bobber_landed
signal found_bite

@export var water_level := -25
@export var float_amplitude := 0.2
@export var float_speed := 2.0

# how long til the fish bites between
var wait_time_min := 1.0
var wait_time_max := 3.0

var float_timer := 0.0

var landed: bool = false
var reeling: bool = false
var waiting_for_fish: bool = false

func initialize(initial_velocity: Vector3) -> void:
	linear_velocity = initial_velocity

func _process(delta):
	if !reeling:
		# Example: detect when bobber hits water level at y = 0
		if not landed and global_transform.origin.y <= water_level:
			$water.play()
			landed = true
			linear_velocity = Vector3.ZERO
			emit_signal("bobber_landed", global_transform.origin)
		elif landed:
			float_timer += delta
			var bob_offset = sin(float_timer * float_speed) * float_amplitude
			global_transform.origin.y = water_level + bob_offset
			fish_bite_delay()

func fish_bite_delay():
	if waiting_for_fish:
		return
	waiting_for_fish = true
	var wait_time = randf_range(wait_time_min, wait_time_max)
	await get_tree().create_timer(wait_time).timeout
	emit_signal("found_bite")
