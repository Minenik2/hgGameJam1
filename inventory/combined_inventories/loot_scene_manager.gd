extends CanvasLayer
@onready var inventoryPlayer: Control = $HBoxContainer/MarginContainer/VBoxContainer/inventory
@onready var inventoryReward: Control = $HBoxContainer/MarginContainer2/VBoxContainer/inventoryReward
@onready var inventoryShop: Control = $HBoxContainer/MarginContainer2/shop/inventoryShop

@onready var player_stats: VBoxContainer = $HBoxContainer/MarginContainer2/playerStats


func _ready() -> void:
	DialogueDisplay.connect("global_signal", on_dialogue_signal)

func _on_done_button_down() -> void:
	closeUi()

func startLoot(currentFish: FishData) -> void:
	hide_all()
	$HBoxContainer.show()
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
	hide_all()
	hide()
	MouseManager.hide_mouse()
	$HBoxContainer.show()

func fillStats():
	$HBoxContainer/MarginContainer2/playerStats/statMoney.text = "IKO: " + str(Database.money)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		if visible:
			closeUi()
		else:
			AudioManager.playMenuClick()
			$HBoxContainer/MarginContainer2/playerStats/statMoney.text = "IKO: " + str(Database.money)
			hide_all()
			player_stats.show()
			show()
			MouseManager.show_mouse()
			inventoryPlayer.active = true

func hide_all():
	$HBoxContainer/MarginContainer2/VBoxContainer.hide() # reward ui
	$HBoxContainer/MarginContainer2/playerStats.hide()
	$HBoxContainer/MarginContainer2/shop.hide()
	$upgradeShop.hide()
	
	inventoryReward.active = false
	inventoryPlayer.active = false
	inventoryShop.active = false

func startShop():
	hide_all()
	$HBoxContainer/MarginContainer2/shop.updateVisual()
	$HBoxContainer/MarginContainer2/shop.show()
	show()
	MouseManager.show_mouse()
	inventoryShop.active = true
	inventoryPlayer.active = true

func on_dialogue_signal(command):
	if command == "shopUI":
		startShop()
	elif command == "upgradeUI":
		startUpgrades()

func startUpgrades():
	hide_all()
	$HBoxContainer.hide()
	$upgradeShop.show()
	show()
	MouseManager.show_mouse()

func _on_upgrade_shop_done_pressed() -> void:
	closeUi()
