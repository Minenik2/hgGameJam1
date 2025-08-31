extends Area2D

@export var dialogue_resource: JSON
@export var trigger_id: String  # Give each area a unique ID
@export var repeating:bool = false
@export var player: CharacterBody2D
@export var walk_right: bool

var triggered = false

func _ready():
	if Database.triggered_flags.has(trigger_id):
		triggered = Database.triggered_flags[trigger_id]
	else:
		Database.triggered_flags[trigger_id] = false

func _on_body_entered(body: Node2D) -> void:
	match trigger_id:
		"seeBodyFirst":
			if DialogueDisplay.state["bodyInvestigated"]:
				return
	
	if repeating and body.is_in_group("player"):
		DialogueDisplay.show()
		DialogueDisplay.start_dialogue(dialogue_resource)
		player.is_interacting = true
		if walk_right:
			player.walk_for_seconds(Vector2.RIGHT, 0.5)
		
	elif !triggered and body.is_in_group("player"):
		DialogueDisplay.show()
		DialogueDisplay.start_dialogue(dialogue_resource)
		player.is_interacting = true
		triggered = true
		Database.triggered_flags[trigger_id] = true
