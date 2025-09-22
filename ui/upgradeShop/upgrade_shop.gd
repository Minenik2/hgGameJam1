extends Control

@onready var info: Label = %Info
@onready var cost = %cost
@onready var power_info = %powerInfo


#buttons
@onready var rod: Button = $MarginContainer/PanelContainer/VBoxContainer/MarginContainer2/HBoxContainer/rod
@onready var bait: Button = $MarginContainer/PanelContainer/VBoxContainer/MarginContainer2/HBoxContainer/bait
@onready var wire: Button = $MarginContainer/PanelContainer/VBoxContainer/MarginContainer2/HBoxContainer/wire

const COLOR_COMMON     = Color(0.272, 0.595, 0.494, 1.0) # green
const COLOR_RARE       = Color(0.598, 0.32, 0.681, 1.0) # purple
const COLOR_LEGENDARY  = Color(0.79, 0.414, 0.126, 1.0) # orange

signal donePressed

func _ready() -> void:
	updateAll()

func _on_rod_mouse_entered() -> void:
	info.text = "Decrease the time to get a catch"
	updateRod()

func _on_bait_mouse_entered() -> void:
	info.text = "Increase chance to catch an additional fish"
	updateBait()

func _on_wire_mouse_entered() -> void:
	info.text = "Increase chance to catch rarer fish"
	updateWire()

func updateAll():
	rod.text = "Circuit Rod\n" + str(Database.levelRod) + "/" + str(Database.levelMaxRod)
	bait.text = "Splick Bait\n" + str(Database.levelBait) + "/" + str(Database.levelMaxBait)
	wire.text = "Vein Wire\n" + str(Database.levelWire) + "/" + str(Database.levelMaxWire)

func updateRod():
	cost.text = "IKO Owned: [color={0}]{1}[/color] IKO Cost: [color={2}]{3}[/color]".format([
		COLOR_COMMON.to_html(), Database.money,   # Owned
		COLOR_RARE.to_html(), Database.costRod  # Cost
	])
	power_info.text = "Catch rate: [color={0}]{1}~{2} seconds[/color]".format([
		COLOR_LEGENDARY.to_html(),
		Database.wait_time_min,
		Database.wait_time_max
	])

func updateBait():
	cost.text = "IKO Owned: [color={0}]{1}[/color] IKO Cost: [color={2}]{3}[/color]".format([
		COLOR_COMMON.to_html(), Database.money,   # Owned
		COLOR_RARE.to_html(), Database.costBait  # Cost
	])
	power_info.text = "Double Catch Chance: [color={0}]{1}%[/color]".format(
		[COLOR_LEGENDARY.to_html(),
		str(Database.doubleChance)]
	)

func updateWire():
	cost.text = "IKO Owned: [color={0}]{1}[/color] IKO Cost: [color={2}]{3}[/color]".format([
		COLOR_COMMON.to_html(), Database.money,   # Owned
		COLOR_RARE.to_html(), Database.costWire  # Cost
	])
	power_info.text = """[color={0}]Common: {1}%[/color] [color={2}]Rare: {3}%[/color] [color={4}]Legendary: {5}%[/color]""".format([
		COLOR_COMMON.to_html(), Gacha.pull_rates["common"],
		COLOR_RARE.to_html(), Gacha.pull_rates["rare"],
		COLOR_LEGENDARY.to_html(), Gacha.pull_rates["legendary"]
	])

func _on_rod_pressed() -> void:
	if Database.money >= Database.costRod and Database.levelRod < Database.levelMaxRod:
		AudioManager.playShopSell()
		Database.buyRod()
		updateAll()
		updateRod()
	else:
		AudioManager.playMenuClick()


func _on_bait_pressed() -> void:
	if Database.money >= Database.costBait and Database.levelBait < Database.levelMaxBait:
		AudioManager.playShopSell()
		Database.buyBait()
		updateAll()
		updateBait()
	else:
		AudioManager.playMenuClick()


func _on_wire_pressed() -> void:
	if Database.money >= Database.costWire and Database.levelWire < Database.levelMaxWire:
		AudioManager.playShopSell()
		Database.buyWire()
		updateAll()
		updateWire()
	else:
		AudioManager.playMenuClick()


func _on_done_pressed() -> void:
	AudioManager.playMenuClick()
	hide()
	donePressed.emit()
