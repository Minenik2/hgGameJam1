extends CharacterBody3D

@export var speed: float = 5.0
@export var jump_velocity: float = 7
@export var camera: Camera3D

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var pitch: float = 0.0  # Up/down rotation

# audio for footsteps
var step_timer := 0.0
var step_interval := 0.4  # Time between step sounds, adjust as needed

# landing detection
var was_on_floor: bool = false
var landed_enabled := false

# dialogue system / dont move when iteracting
var is_interacting = false

# fishing system
@onready var fishing_rod = $fishing_rod

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# Enable landing detection after 0.1 sec
	await get_tree().create_timer(0.1).timeout
	landed_enabled = true

func _unhandled_input(event):
	# Toggle mouse capture with Input Map action
	if Input.is_action_just_pressed("pause"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		elif !is_interacting:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	# Mouse look (only when captured)
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * GameSettingManager.mouse_sensitivity)
		pitch = clamp(pitch - event.relative.y * GameSettingManager.mouse_sensitivity, -PI/2, PI/2)
		camera.rotation.x = pitch

func _physics_process(delta):
	var velocity = self.velocity
	step_timer -= delta # step sound

	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Movement input
	if !is_interacting:
		var input_dir = Input.get_vector("left", "right", "up", "down")
		var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

		if direction != Vector3.ZERO:
			if step_timer <= 0.0 and is_on_floor() and AudioManager.isPlayingLand():
				AudioManager.playSteps()
				step_timer = step_interval
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)

		# Jump
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = jump_velocity

	self.velocity = velocity
	move_and_slide()

	# Landing sound check
	if landed_enabled and is_on_floor() and not was_on_floor and velocity.y <= 0:
		AudioManager.playLand()

	# Update last floor state
	was_on_floor = is_on_floor()
