extends CanvasLayer
@onready var inventoryPlayer: Control = $HBoxContainer/MarginContainer/VBoxContainer/inventory
@onready var inventoryReward: Control = $HBoxContainer/MarginContainer2/VBoxContainer/inventory2

@onready var player_stats: VBoxContainer = $HBoxContainer/MarginContainer2/playerStats


func _on_done_button_down() -> void:
	closeUi()

func startLoot(currentFish: FishData) -> void:
	PauseMenu.playerInteracting = true
	$HBoxContainer/MarginContainer2/VBoxContainer.show()
	show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	inventoryReward.clear_inventory()
	inventoryReward.active = true
	inventoryPlayer.active = true
	await get_tree().process_frame
	await get_tree().process_frame
	inventoryReward.spawn_item_to_inventory(currentFish)
	# % chance to spawn an extra one
	if randi() % 100 < Database.doubleChance:  # generates a number 0-99
		inventoryReward.spawn_item_to_inventory(currentFish)

func closeUi():
	AudioManager.playMenuClick()
	$HBoxContainer/MarginContainer2/playerStats.hide()
	hide()
	inventoryReward.active = false
	inventoryPlayer.active = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	PauseMenu.playerInteracting = false

func fillStats():
	$HBoxContainer/MarginContainer2/playerStats/statMoney.text = "IKO: " + str(Database.money)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		if visible:
			closeUi()
		elif !PauseMenu.playerInteracting:
			$HBoxContainer/MarginContainer2/VBoxContainer.hide()
			player_stats.show()
			show()
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			PauseMenu.playerInteracting = true
			inventoryPlayer.active = true
			
