extends CanvasLayer
const DEFAULT_STATE := {
}

@onready var state = DEFAULT_STATE.duplicate()

signal dialogue_ended
signal cutscene_start

#func _ready() -> void:
	
	
func start_dialogue(dialogue_json: JSON):
	$DialogueBox.is_dialogue_done = false
	($EzDialogue as EzDialogue).start_dialogue(dialogue_json, state)

func _on_ez_dialogue_dialogue_generated(response: DialogueResponse) -> void:
	AudioManager.playDialogueClick()
	$DialogueBox.clear_dialogue_box()
	$DialogueBox.add_text(response.text)
	if response.choices.is_empty():
		$DialogueBox.add_choice("...")
	else:
		for choice in response.choices:
			$DialogueBox.add_choice(choice)


func _on_ez_dialogue_custom_signal_received(value: Variant) -> void:
	var params = value.split(",")
	if params[0] == "set":
		var variable_name = params[1]
		var variable_value = params[2]
		state[variable_name] = variable_value


func _on_ez_dialogue_end_of_dialogue_reached() -> void:
	$DialogueBox.is_dialogue_done = true
	dialogue_ended.emit()
	
func reset_state():
	state = DEFAULT_STATE.duplicate()
