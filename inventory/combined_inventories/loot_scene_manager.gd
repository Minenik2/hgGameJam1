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
	$HBoxContainer/MarginContainer2/VBoxContainer/IkoHeld.text = "IKO Held: 0"
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
	$CollectionUi.discover_fish(currentFish)
	# % chance to spawn an extra one
	if randi() % 100 < Database.doubleChance and currentFish.item_type == FishData.TYPE.FISH:  # generates a number 0-99
		inventoryReward.spawn_item_to_inventory(currentFish)

func closeUi():
	AudioManager.playMenuClick()
	if !inventoryReward.hasKeyItems.is_empty():
		%tooltip_middle.text = "Please pickup a key item"
		return
	if inventoryPlayer.item_held:
		%tooltip_middle.text = "Please put down the held item"
		return
	%tooltip_middle.text = ""
	
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
			startInventory()
	elif event.is_action_pressed("collection"):
		if visible:
			closeUi()
		else:
			startCollection()

func hide_all():
	$HBoxContainer/MarginContainer2/VBoxContainer.hide() # reward ui
	$HBoxContainer/MarginContainer2/playerStats.hide()
	$HBoxContainer/MarginContainer2/shop.hide()
	%questItems.hide()
	$upgradeShop.hide()
	$CollectionUi.hide()
	
	inventoryReward.active = false
	inventoryPlayer.active = false
	inventoryShop.active = false
	%inventoryQuest.active = false

func startCollection():
	AudioManager.playMenuClick()
	hide_all()
	$HBoxContainer.hide()
	$CollectionUi.show()
	show()
	MouseManager.show_mouse()

func startInventory():
	AudioManager.playMenuClick()
	$HBoxContainer/MarginContainer2/playerStats/statMoney.text = "IKO: " + str(Database.money)
	hide_all()
	player_stats.show()
	show()
	MouseManager.show_mouse()
	inventoryPlayer.active = true

func startShop():
	hide_all()
	$HBoxContainer/MarginContainer2/shop.updateVisual()
	$HBoxContainer/MarginContainer2/shop.show()
	show()
	MouseManager.show_mouse()
	inventoryShop.active = true
	inventoryPlayer.active = true

func startQuest():
	hide_all()
	%questItems.show()
	show()
	MouseManager.show_mouse()
	%inventoryQuest.active = true
	inventoryPlayer.active = true
	

func on_dialogue_signal(command):
	if command == "shopUI":
		startShop()
	elif command == "upgradeUI":
		startUpgrades()
	elif command == "sitriUI":
		startQuest()

func startUpgrades():
	hide_all()
	$upgradeShop.updateAll()
	$HBoxContainer.hide()
	$upgradeShop.show()
	show()
	MouseManager.show_mouse()

func _on_upgrade_shop_done_pressed() -> void:
	closeUi()

func _on_collection_ui_done_pressed() -> void:
	closeUi()
