extends StaticBody2D

@export var dialogue_resource: JSON
@export var player: CharacterBody2D
@export var destroy: bool = false
@export var trigger_event: bool = false # only for the knife sequence in ending

@export_group("Teleporter Settings")
@export var teleporter: bool = false

@export_subgroup("If Teleporter Is Enabled")
@export var code: String
@export var check: String = "default"
@export_file("*.tscn") var target_scene: String


func _ready():
	# Fallback to default if player not manually assigned in inspector
	if player == null:
		player = get_node("../player")

func on_interact():
	if Database.hasKnife:
		SfXplayer.playKnifeStab()
		$Sprite2D.texture = load("res://art/body.png")
		Database.killedAmount += 1
		if Database.killedAmount > 4:
			DialogueDisplay.show()
			DialogueDisplay.start_dialogue(load("res://dialogue/endingSequence.json"))
			player.is_interacting = true
		return
	
	if trigger_event:
		Database.hasKnife = true
	
	if teleporter and DialogueDisplay.state[check]:
		SfXplayer.playStairs()
		Database.teleportCode = code
		TransitionScreen.transition()
		await TransitionScreen.on_transition_finished
		get_tree().change_scene_to_file(target_scene)
	else:
		DialogueDisplay.show()
		DialogueDisplay.start_dialogue(dialogue_resource)
		player.is_interacting = true
	
	if destroy:
		queue_free()
