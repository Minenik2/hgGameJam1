extends Control

@export var fish_list: Array[FishData] = []  # preload all fish here in order
@onready var fish_texture: TextureRect = %FishTexture
@onready var fish_name: Label = %FishName
@onready var fish_desc: RichTextLabel = %FishDescription
@onready var page_label: Label = %PageLabel

signal donePressed

var discovered: Dictionary = {}  # { fish_name: true/false }
var current_index: int = 0

func _ready():
	# Init all fish as undiscovered
	for fish in fish_list:
		discovered[fish.name] = false
	update_page()

func discover_fish(fish: FishData) -> void:
	if !discovered[fish.name]:
		discovered[fish.name] = true
		update_page()

func next_page():
	if current_index < fish_list.size() - 1:
		current_index += 1
		animate_page_change(current_index, false)
		update_page()

func prev_page():
	if current_index > 0:
		current_index -= 1
		animate_page_change(current_index, true)
		update_page()

func update_page():
	var fish: FishData = fish_list[current_index]
	var is_found: bool = discovered[fish.name]

	if is_found:
		fish_texture.texture = fish.texture
		fish_texture.modulate = Color(1, 1, 1, 1)
		fish_name.text = fish.name
		fish_desc.text = fish.description
	else:
		fish_texture.texture = fish.texture
		fish_texture.modulate = Color(0.0, 0.0, 0.0, 0.2) # faded
		fish_name.text = "???"
		fish_desc.text = "Unknown creature."

	page_label.text = "Page %d / %d" % [current_index + 1, fish_list.size()]

func animate_page_change(new_index: int, right: bool):
	var tween = create_tween()

	current_index = new_index
	update_page()  # updates $Panel instantly to next page

	position.x = size.x
	if right: 
		position.x = -size.x
	tween.tween_property($".", "position:x", 0, 0.1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func _on_prev_button_pressed() -> void:
	AudioManager.playMenuClick()
	prev_page()


func _on_next_button_pressed() -> void:
	AudioManager.playMenuClick()
	next_page()


func _on_done_pressed() -> void:
	donePressed.emit()
