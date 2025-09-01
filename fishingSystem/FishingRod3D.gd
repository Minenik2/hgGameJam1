extends Node3D

@export var camera: Camera3D
@export var bobber: Node3D
@export var rod_tip: Node3D
@export var line: MeshInstance3D   # Cylinder for the line

# --- Signals ---
signal cast_started
signal reeling_started
signal reeling_finished
signal bite_started

# --- Casting Variables ---
var is_casting := false
var velocity: Vector3 = Vector3.ZERO
const GRAVITY := 9.8
var cast_power_base := Vector3(0, 5, -10) # small push forward
var cast_power := 10.0

# --- Floating Variables ---
var floating := false
var float_timer := 0.0
const FLOAT_AMPLITUDE := 0.2
const FLOAT_SPEED := 2.0
var base_water_pos := Vector3.ZERO

# --- Reeling Variables ---
var reeling_in := false
const REEL_SPEED := 5.0

# --- Fish ---
var caught := false
var fish_on_line := false
var minigame_active := false
var catch_window := 0.8

func _process(delta: float) -> void:
	if reeling_in:
		bobber.global_position = bobber.global_position.move_toward(rod_tip.global_position, REEL_SPEED * delta)
		_update_line()

		if bobber.global_position.distance_to(rod_tip.global_position) < 0.3:
			reeling_finished.emit()
			reset_fishing()
		return
	
	if is_casting and not fish_on_line:
		if not floating:
			velocity.y -= GRAVITY * delta
			bobber.global_position += velocity * delta
			_update_line()

			# Hit "water level"
			if bobber.global_position.y <= 0.0:  # assume water plane at y=0
				bobber.global_position.y = 0.0
				velocity = Vector3.ZERO
				floating = true
				base_water_pos = bobber.global_position
		else:
			float_timer += delta
			var bob_offset = sin(float_timer * FLOAT_SPEED) * FLOAT_AMPLITUDE
			bobber.global_position.y = base_water_pos.y + bob_offset
			_update_line()

func _unhandled_input(event: InputEvent) -> void:
	#if event.is_action_pressed("interact"):
	#	if not is_casting:
	#		begin_charge()
	#elif event.is_action_released("interact"):
	#	if is_charging:
	#		end_charge_and_cast(true)
	#	elif is_casting:
	#		try_catch()
	
	if event.is_action_pressed("interact"):
		cast()

func cast():
	if is_casting:
		return
	
	cast_started.emit()
	is_casting = true
	floating = false
	reeling_in = false
	caught = false
	fish_on_line = false
	
	bobber.visible = true
	
	# Start bobber just in front of camera (rod tip position)
	bobber.global_position = rod_tip.global_position + camera.global_basis.z * -0.5
	
	# Launch forward in camera direction
	var dir: Vector3 = -camera.global_basis.z.normalized()
	velocity = dir * cast_power + Vector3(0, 3, 0) # give it some upward arc

	_update_line()

func reset_fishing():
	is_casting = false
	floating = false
	reeling_in = false
	velocity = Vector3.ZERO
	float_timer = 0.0
	bobber.visible = false
	_update_line(true)

func start_reeling_in():
	reeling_in = true
	floating = false
	velocity = Vector3.ZERO
	reeling_started.emit()

# --- Line update ---
func _update_line(clear_line: bool = false):
	if clear_line:
		line.visible = false
		return
	
	line.visible = true
	var start = rod_tip.global_position
	var end = bobber.global_position
	var mid = (start + end) * 0.5
	line.global_position = mid
	
	var dir = end - start
	var dist = dir.length()
	line.scale = Vector3(0.02, dist * 0.5, 0.02) # thin cylinder
	line.look_at(end, Vector3.UP)
	line.rotate_object_local(Vector3.RIGHT, deg_to_rad(90))
