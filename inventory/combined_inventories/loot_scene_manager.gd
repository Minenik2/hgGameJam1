extends CanvasLayer
@onready var inventoryPlayer: Control = $HBoxContainer/MarginContainer/VBoxContainer/inventory
@onready var inventoryReward: Control = $HBoxContainer/MarginContainer2/VBoxContainer/inventory2

@onready var player_stats: VBoxContainer = $HBoxContainer/MarginContainer2/playerStats


func _on_done_button_down() -> void:
	closeUi()

func startLoot(currentFish: FishData) -> void:
	$HBoxContainer/MarginContainer2/VBoxContainer.show()
	show()
	MouseManager.show_mouse()
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
	MouseManager.hide_mouse()

func fillStats():
	$HBoxContainer/MarginContainer2/playerStats/statMoney.text = "IKO: " + str(Database.money)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		if visible:
			closeUi()
		else:
			AudioManager.playMenuClick()
			$HBoxContainer/MarginContainer2/VBoxContainer.hide()
			player_stats.show()
			show()
			MouseManager.show_mouse()
			inventoryPlayer.active = true
			
