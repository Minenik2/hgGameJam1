extends CanvasLayer
@onready var inventoryPlayer: Control = $HBoxContainer/MarginContainer/VBoxContainer/inventory
@onready var inventoryReward: Control = $HBoxContainer/MarginContainer2/VBoxContainer/inventory2


func _on_done_button_down() -> void:
	AudioManager.playMenuClick()
	hide()
	inventoryReward.active = false
	inventoryPlayer.active = false
	PauseMenu.playerInteracting = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func startLoot(currentFish: FishData) -> void:
	PauseMenu.playerInteracting = true
	show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	inventoryReward.clear_inventory()
	inventoryReward.active = true
	inventoryPlayer.active = true
	await get_tree().process_frame
	await get_tree().process_frame
	inventoryReward.spawn_item_to_inventory(currentFish)
	# 5% chance to spawn an extra one
	if randi() % 100 < 5:  # generates a number 0-99
		inventoryReward.spawn_item_to_inventory(currentFish)
