extends Area3D

@export var dialogue_resource: JSON
@export var player: CharacterBody3D
@export var destroy: bool = false
@export var trigger_event: bool = false # only for the knife sequence in ending

@export_group("Teleporter Settings")
@export var teleporter: bool = false

@export_subgroup("If Teleporter Is Enabled")
# the code is used by the spawner to choose the spawn location
@export var code: String 
# checks if dualogueDisplay has a specific state set to true
@export var check: String = "default"
@export_file("*.tscn") var target_scene: String

var canInteract = false


func _ready():
	# Fallback to default if player not manually assigned in inspector
	if player == null:
		player = get_node("../player")
	DialogueDisplay.connect("dialogue_ended", self.dialogue_ended)

func on_interact():
	if teleporter and DialogueDisplay.state[check]:
		#SfXplayer.playStairs()
		#Database.teleportCode = code
		#TransitionScreen.transition()
		#await TransitionScreen.on_transition_finished
		get_tree().change_scene_to_file(target_scene)
	elif !player.is_interacting:
		DialogueDisplay.show()
		DialogueDisplay.start_dialogue(dialogue_resource)
		dialogue_started()
	
	if destroy:
		queue_free()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and canInteract:
		on_interact()
		
# will be called when the dialogue starts
func dialogue_started():
	Tooltip.hide()
	player.is_interacting = true
	PauseMenu.playerInteracting = true # TODO FIX TAB BUG
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

# will be called when the dialogue ends
func dialogue_ended():
	DialogueDisplay.hide()
	Tooltip.show()
	player.is_interacting = false
	PauseMenu.playerInteracting = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_body_entered(body: Node3D) -> void:
	Tooltip.show()
	canInteract = true

func _on_body_exited(body: Node3D) -> void:
	Tooltip.hide()
	canInteract = false
