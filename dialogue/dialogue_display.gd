extends CanvasLayer
const DEFAULT_STATE := {
	talkedMarbas = false,
	talkedSitri = false,
	inheritanceRep = 0,
	refusalRep = 0,
	solvedFragment1 = false,
	solvedFragment2 = false,
	solvedFragment3 = false,
}

@onready var state = DEFAULT_STATE.duplicate()

signal dialogue_ended
signal global_signal # global signal can be emited in the JSON text along with a string

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
	match params[0]:
		"set":
			var variable_name = params[1]
			var variable_value = params[2]
			state[variable_name] = variable_value
		"globalSignal":
			var variable_pass = params[1] # this value will be passed with the signal
			global_signal.emit(variable_pass)
		"increase":
			var variable_name = params[1]
			var variable_value = params[2]
			state[variable_name] = state[variable_name] + int(variable_value)
		"flipCoin":
			if randi() % 2 == 0:
				state["flipCoin"] = "heads"
			else:
				state["flipCoin"] = "tails"
		">":
			var variable_name = params[1]
			var variable_value = params[2]
			var addbool = "bool"
			state[variable_name + addbool] = state[variable_name] > int(variable_value)


func _on_ez_dialogue_end_of_dialogue_reached() -> void:
	$DialogueBox.is_dialogue_done = true
	dialogue_ended.emit()
	
func reset_state():
	state = DEFAULT_STATE.duplicate()
