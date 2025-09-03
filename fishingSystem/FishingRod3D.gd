extends Node3D

@onready var line: MeshInstance3D = $line
@onready var bobberVisual: Node3D = $bobber3D
@export var bobber_scene: PackedScene
@export var minigame: CanvasLayer
@export var player: CharacterBody3D
@export var camera: Camera3D

# --- Signals ---
signal cast_started
signal reeling_started
signal reeling_finished
signal bite_started

# --- Constants ---
const GRAVITY := 9.8 * 20  # adjust gravity strength
const FLOAT_AMPLITUDE := 0.2
const FLOAT_SPEED := 2.0
const REEL_SPEED := 20.0
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

# Spawned Bobber
var bobberSpawn = null

# player inputs
func _unhandled_input(event: InputEvent) -> void:
	if !player.is_interacting:
		if event.is_action_pressed("interact"):
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
		var target = $modernart/LineStart.global_transform.origin
		var bobber_pos = bobberSpawn.global_transform.origin

		# move bobber toward rod tip
		var direction = (target - bobber_pos)
		var distance = direction.length()

		if distance > 0.1:
			direction = direction.normalized()
			bobberSpawn.global_transform.origin += direction * REEL_SPEED * delta
		else:
			if caught: AudioManager.playHookCatch()
			# reel finished
			bobberSpawn.queue_free()
			bobberSpawn = null
			is_casting = false
			reeling_in = false
			reeling_finished.emit()
			reset_fishing()

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
	$shoot.play()
	is_casting = true
	caught = false
	fish_on_line = false
	bobberVisual.visible = false
	
	# Calculate cast direction from camera/rod orientation
	cast_direction = -camera.global_transform.basis.z.normalized()
	var initial_velocity = cast_direction * power + Vector3.UP * 0.5
	
	# Spawn bobber
	bobberSpawn = bobber_scene.instantiate()
	get_tree().current_scene.add_child(bobberSpawn)
	
	bobberSpawn.connect("found_bite", self.fish_bite_delay)
	
	# Place it slightly in front of the rod
	bobberSpawn.global_transform.origin = $bobberSpawner.global_transform.origin
	
	# Assign rod tip + bobber to line script
	line.rod_tip = $modernart/LineStart
	line.bobber = bobberSpawn
	
	# Give it velocity
	bobberSpawn.initialize(initial_velocity)
	cast_started.emit()

# --- Fish Bite ---
func fish_bite_delay() -> void:
	if minigame_active or reeling_in:
		return
	show_bite()

func show_bite() -> void:
	if caught or fish_on_line or minigame_active:
		return
		
	AudioManager.playBite()
	line.flash_red(catch_window)
	fish_on_line = true
	bite_started.emit()
	await get_tree().create_timer(catch_window).timeout
	fish_on_line = false
	if bobberSpawn:
		bobberSpawn.waiting_for_fish = false

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
			bobberSpawn.waiting_for_fish = false
	elif not fish_on_line:
		start_reeling_in()

func start_reeling_in() -> void:
	if minigame_active: return
	
	$reel.play()
	bobberSpawn.reeling = true
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
	bobberVisual.visible = true
