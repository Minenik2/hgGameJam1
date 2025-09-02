extends Node3D

@onready var bobber: Node3D = $bobber3D
@export var bobber_scene: PackedScene
@export var minigame: CanvasLayer
@export var player: CharacterBody3D

# --- Signals ---
signal cast_started
signal reeling_started
signal reeling_finished
signal bite_started

# --- Constants ---
const GRAVITY := 9.8 * 20  # adjust gravity strength
const FLOAT_AMPLITUDE := 0.2
const FLOAT_SPEED := 2.0
const REEL_SPEED := 5.0
const ROD_TIP_POSITION := Vector3(0.5, -0.5, 1.0) # relative to player/rod

# --- State ---
var is_casting := false
var velocity := Vector3.ZERO
var floating := false
var float_timer := 0.0
var base_water_pos := Vector3.ZERO
var reeling_in := false
var caught := false
var fish_on_line := false
var minigame_active := false
var catch_window := 0.8

# --- Charging ---
var is_charging := false
var cast_power := 0.0
var max_cast_power := 60.0
var charge_speed := 1
var can_cast := true

# --- Casting Direction ---
var cast_direction := Vector3.FORWARD

# player inputs
func _unhandled_input(event: InputEvent) -> void:
	if !player.is_interacting:
		if event.is_action_pressed("interact"):
			cast(50)
			if not is_casting:
				begin_charge()
		elif event.is_action_released("interact"):
			if is_charging:
				end_charge_and_cast()
			elif is_casting:
				try_catch()

func _process(delta: float) -> void:
	# --- Charging ---
	if is_charging:
		cast_power += charge_speed
		if cast_power > max_cast_power:
			cast_power = 0
		$castBar/castBar.value = cast_power
		$castBar/castBar.visible = true

	# --- Reeling ---
	if reeling_in:
		bobber.global_transform.origin = bobber.global_transform.origin.move_toward(global_transform.origin + ROD_TIP_POSITION, REEL_SPEED * delta)
		if bobber.global_transform.origin.distance_to(global_transform.origin + ROD_TIP_POSITION) < 0.1:
			if caught: AudioManager.playHookCatch()
			if bobber.has_node("Fish"): bobber.get_node("Fish").hide()
			reeling_finished.emit()
			reset_fishing()
		return

	# --- Casting / Floating ---
	if is_casting and not fish_on_line:
		if not floating:
			velocity.y -= GRAVITY * delta
			bobber.global_translate(velocity * delta)
			if bobber.global_transform.origin.y <= 0:  # water level at y=0
				bobber.global_transform.origin.y = 0
				velocity = Vector3.ZERO
				floating = true
				base_water_pos = bobber.global_transform.origin
				fish_bite_delay()
		else:
			float_timer += delta
			var bob_offset = sin(float_timer * FLOAT_SPEED) * FLOAT_AMPLITUDE
			var new_pos = base_water_pos + Vector3(0, bob_offset, 0)
			bobber.global_transform.origin = new_pos

# --- Cast Functions ---
func begin_charge() -> void:
	if not is_casting and can_cast:
		is_charging = true
		cast_power = 0.0
		$castBar.visible = true

func end_charge_and_cast() -> void:
	if is_charging and can_cast:
		is_charging = false
		can_cast = false
		
		# Optional visual feedback: pulse the bar briefly
		var tween := create_tween()
		tween.tween_property($castBar/castBar, "scale", Vector2(1.1, 1.1), 0.1).set_trans(Tween.TRANS_SINE)
		tween.tween_property($castBar/castBar, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_SINE)

		# Pause to show cast power briefly
		await get_tree().create_timer(0.3).timeout
		
		$castBar/castBar.visible = false
		cast(cast_power)
		cast_power = 0.0
		can_cast = true

func cast(power: float) -> void:
	is_casting = true
	caught = false
	fish_on_line = false
	
	# Calculate cast direction from camera/rod orientation
	cast_direction = -$bobberSpawner.global_transform.basis.z
	var initial_velocity = cast_direction * (power + 30) + Vector3.UP * (power * 0.5)
	
	# Spawn bobber
	bobber = bobber_scene.instantiate()
	get_tree().current_scene.add_child(bobber)
	
	# Place it slightly in front of the rod
	bobber.global_transform.origin = $bobberSpawner.global_transform.origin
	
	# Give it velocity
	bobber.initialize(initial_velocity)
	cast_started.emit()

# --- Fish Bite ---
func fish_bite_delay() -> void:
	if minigame_active:
		return
	var wait_time = randf_range(1.0, 3.0)
	await get_tree().create_timer(wait_time).timeout
	show_bite()

func show_bite() -> void:
	if caught or fish_on_line or not floating or minigame_active:
		return
		
	AudioManager.playBite()
	fish_on_line = true
	bite_started.emit()
	await get_tree().create_timer(catch_window).timeout
	fish_on_line = false
	fish_bite_delay()

# --- Reeling ---
func try_catch() -> void:
	if fish_on_line and not minigame_active:
		minigame_active = true
		minigame.start()
		var success = await minigame.fish_caught
		minigame_active = false

		if success:
			caught = true
			fish_on_line = false
			start_reeling_in()
		else:
			fish_on_line = false
			fish_bite_delay()
	elif floating and not fish_on_line:
		start_reeling_in()

func start_reeling_in() -> void:
	if minigame_active: return
	reeling_in = true
	floating = false
	velocity = Vector3.ZERO
	reeling_started.emit()

func reset_fishing() -> void:
	reeling_in = false
	floating = false
	float_timer = 0.0
	is_casting = false
	fish_on_line = false
	velocity = Vector3.ZERO
	caught = false
	bobber.visible = false
