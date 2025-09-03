extends CanvasLayer

@onready var name_2: Label = $Panel/MarginContainer/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/name2
@onready var cm: Label = $Panel/MarginContainer/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/PanelContainer2/MarginContainer2/HBoxContainer/VBoxContainer/cm
@onready var kg: Label = $Panel/MarginContainer/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/PanelContainer2/MarginContainer2/HBoxContainer/VBoxContainer2/kg
@onready var rarity: Label = $Panel/MarginContainer/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/PanelContainer3/MarginContainer3/VBoxContainer2/rarity
@onready var iko: Label = $Panel/MarginContainer/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/PanelContainer4/MarginContainer3/VBoxContainer2/iko

@onready var texture_rect: TextureRect = $Panel/MarginContainer/HBoxContainer/PanelContainer2/MarginContainer/VBoxContainer/TextureRect
@onready var desc: RichTextLabel = $Panel/MarginContainer/HBoxContainer/PanelContainer2/MarginContainer/VBoxContainer/PanelContainer/MarginContainer/RichTextLabel

func caught() -> void:
	PauseMenu.playerInteracting = true
	updateText($Panel.roll_loot())
	$".".show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_button_pressed() -> void:
	AudioManager.playMenuClick()
	PauseMenu.playerInteracting = false
	$".".hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func updateText(fishData: FishData):
	var fishDataDict = fishData.generate_instance()
	
	name_2.text = fishDataDict["name"]
	cm.text = "%0.2f" % fishDataDict["dimension"] + " cm"
	kg.text = "%0.2f" % fishDataDict["weight"] + " kg"
	iko.text = str(fishDataDict["price"]) + " IKO"
	match fishDataDict["rarity"]:
		fishData.RARITY.COMMON:
			rarity.text = "Common"
		fishData.RARITY.RARE:
			rarity.text = "Rare"
		fishData.RARITY.LEGENDARY:
			rarity.text = "Legendary"
	texture_rect.texture = fishDataDict["texture"]
	desc.text = fishDataDict["description"]
