extends Area3D

@export var dialogue_resource: JSON
@export var player: CharacterBody3D
@export var destroy: bool = false

@export_group("Teleporter Settings")
@export var teleporter: bool = false

@export_subgroup("If Teleporter Is Enabled")
# the code is used by the spawner to choose the spawn location
@export var code: String 
# checks if dualogueDisplay has a specific state set to true
@export var check: String = "default"
@export_file("*.tscn") var target_scene: String

var canInteract = false
# to fix multiple interaction areas in one enviroment
var dialogueStarted = false

var toBeDestroyed = false 


func _ready():
	if NodeDestroyer.is_destroyed(self):
		queue_free() # already destroyed before
		return
	# normal setup
	# Fallback to default if player not manually assigned in inspector
	if player == null:
		player = get_node("../player")
	DialogueDisplay.connect("dialogue_ended", self.dialogue_ended)
	DialogueDisplay.connect("global_signal", self.dialogue_signal_recieved)

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
	player.velocity = Vector3(0, 0, 0)
	player.is_interacting = true
	MouseManager.show_mouse()
	dialogueStarted = true

# will be called when the dialogue ends
func dialogue_ended():
	if dialogueStarted:
		DialogueDisplay.hide()
		if !toBeDestroyed:
			Tooltip.show()
		MouseManager.hide_mouse()
			
		# small hump so that the player doesnt jump when ending dialogue with space
		await get_tree().create_timer(0.2).timeout
		player.is_interacting = false
		dialogueStarted = false
		
		if toBeDestroyed:
			destroy_object()

func _on_body_entered(_body: Node3D) -> void:
	Tooltip.show()
	canInteract = true

func _on_body_exited(_body: Node3D) -> void:
	Tooltip.hide()
	canInteract = false

func dialogue_signal_recieved(command):
	if command == "END" and canInteract:
		hide()
		toBeDestroyed = true

func destroy_object():
	NodeDestroyer.mark_destroyed(self)
	queue_free()
