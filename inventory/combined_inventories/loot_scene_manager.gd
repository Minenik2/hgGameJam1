extends CanvasLayer
@onready var inventoryPlayer: Control = $HBoxContainer/MarginContainer/VBoxContainer/inventory
@onready var inventoryReward: Control = $HBoxContainer/MarginContainer2/VBoxContainer/inventory2


func _on_done_button_down() -> void:
	AudioManager.playMenuClick()
	hide()
	PauseMenu.playerInteracting = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func startLoot() -> void:
	PauseMenu.playerInteracting = true
	show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	await get_tree().process_frame
	inventoryReward.spawn_item_to_inventory(1)
