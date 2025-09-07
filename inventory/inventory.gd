extends Control

@export var column_count: int = 6
@export var rows: int = 3

@onready var slot_scene = preload("res://inventory/slot.tscn")
@onready var grid_container: GridContainer = $ColorRect/inventoryGrid/VBoxContainer/ScrollContainer/GridContainer
@onready var item_scene = preload("res://inventory/item.tscn")
@onready var scroll_container = $ColorRect/inventoryGrid/VBoxContainer/ScrollContainer
@onready var col_count = grid_container.columns

signal item_picked_up(item)
signal item_placed(item)

var grid_array := []
var item_held = null
var current_slot = null
var can_place := false
var icon_anchor : Vector2
# deactivate while hidden
var active = false

func _ready() -> void:
	grid_container.columns = column_count
	col_count = grid_container.columns
	for i in range(column_count * rows):
		create_slot()

func _unhandled_input(event: InputEvent) -> void:
	if not active:
		return
	
	# Mouse position inside scroll_container?
	var mouse_inside = scroll_container.get_global_rect().has_point(get_global_mouse_position())
	
	if item_held:
		# Rotate item
		if event.is_action_pressed("rotate") and mouse_inside:
			rotate_item()
		
		# Place item
		elif event.is_action_pressed("interact") and mouse_inside:
			place_item()
	else:
		# Pick item
		if event.is_action_pressed("interact") and mouse_inside:
			pick_item()

func create_slot():
	var new_slot = slot_scene.instantiate()
	new_slot.slot_ID = grid_array.size()
	grid_array.push_back(new_slot)
	grid_container.add_child(new_slot)
	new_slot.slot_entered.connect(_on_slot_mouse_entered)
	new_slot.slot_exited.connect(_on_slot_mouse_exited)

func _on_slot_mouse_entered(a_slot):
	icon_anchor = Vector2(10000,10000)
	current_slot = a_slot
	if item_held:
		check_slot_availability(current_slot)
		set_grids.call_deferred(current_slot)

func _on_slot_mouse_exited(a_slot):
	clear_grid()

func check_slot_availability(a_slot) -> void:
	for grid in item_held.item_grids:
		var grid_to_check = a_slot.slot_ID + grid[0] + grid[1] * col_count
		var line_switch_check = a_slot.slot_ID % col_count + grid[0]
		if line_switch_check < 0 or line_switch_check >= col_count:
			can_place = false
			return
		if grid_to_check < 0 or grid_to_check >= grid_array.size():
			can_place = false
			return
		if grid_array[grid_to_check].state == grid_array[grid_to_check].States.TAKEN:
			can_place = false
			return
	can_place = true
		

func set_grids(a_slot):
	for grid in item_held.item_grids:
		var grid_to_check = a_slot.slot_ID + grid[0] + grid[1] * col_count
		var line_switch_check = a_slot.slot_ID % col_count + grid[0]
		if grid_to_check < 0 or grid_to_check >= grid_array.size():
			continue
		if line_switch_check < 0 or line_switch_check >= col_count:
			continue
		if can_place:
			grid_array[grid_to_check].set_color(grid_array[grid_to_check].States.FREE)
			
			if grid[1] < icon_anchor.x: icon_anchor.x = grid[1]
			if grid[0] < icon_anchor.y: icon_anchor.y = grid[0]
		else:
			grid_array[grid_to_check].set_color(grid_array[grid_to_check].States.TAKEN)

func clear_grid():
	for grid in grid_array:
		grid.set_color(grid.States.DEFAULT)

func rotate_item():
	item_held.rotate_item()
	clear_grid()
	if current_slot:
		_on_slot_mouse_entered(current_slot)

func place_item():
	if not can_place or not current_slot:
		return
	if item_held.fishData.rarity == FishData.RARITY.COMMON:
		AudioManager.playDropCommon()
	emit_signal("item_placed", item_held)
		
	var calculated_grid_id = current_slot.slot_ID + icon_anchor.x * col_count + icon_anchor.y
	item_held._snap_to(grid_array[calculated_grid_id].global_position)
	
	item_held.get_parent().remove_child(item_held)
	grid_container.add_child(item_held)
	item_held.global_position = get_global_mouse_position()
	
	item_held.grid_anchor = current_slot
	for grid in item_held.item_grids:
		var grid_to_check = current_slot.slot_ID + grid[0] + grid[1] * col_count
		grid_array[grid_to_check].state = grid_array[grid_to_check].States.TAKEN
		grid_array[grid_to_check].item_stored = item_held
	
	item_held.z_index = 0
	
	item_held = null
	clear_grid()

func pick_item():
	if not current_slot or not current_slot.item_stored:
		return
	
	item_held = current_slot.item_stored
	item_held.selected = true
	
	# only using fish data for playing sound
	# could potentially be improved to also account for grid layout but skill issue
	if item_held.fishData.rarity == FishData.RARITY.COMMON:
		AudioManager.playPickUpCommon()
	
	item_held.z_index = 5
	emit_signal("item_picked_up", item_held)
	
	item_held.get_parent().remove_child(item_held)
	add_child(item_held)
	item_held.global_position = get_global_mouse_position()
	
	for grid in item_held.item_grids:
		var grid_to_check = item_held.grid_anchor.slot_ID + grid[0] + grid[1] * col_count
		grid_array[grid_to_check].state = grid_array[grid_to_check].States.FREE
		grid_array[grid_to_check].item_stored = null
	
	check_slot_availability(current_slot)
	set_grids.call_deferred(current_slot) 

func spawn_item_to_inventory(fish: FishData) -> bool:
	# 1. Create and add to scene tree before anything else
	var new_item = item_scene.instantiate()
	grid_container.add_child(new_item)
	
	new_item.fishData = fish
	var item_id = fish.item_id
	
	# 2. Load item data (now safe since it's in the tree)
	new_item.load_item(item_id)

	# 3. Try to find a slot where the item can fit
	for slot in grid_array:
		item_held = new_item  # Temporarily assign so check_slot_availability works
		check_slot_availability(slot)

		if can_place:
			# Snap to correct anchor position
			var icon_anchor_local = Vector2(10000, 10000)
			for grid in new_item.item_grids:
				if grid[1] < icon_anchor_local.x:
					icon_anchor_local.x = grid[1]
				if grid[0] < icon_anchor_local.y:
					icon_anchor_local.y = grid[0]

			var calculated_grid_id = slot.slot_ID + icon_anchor_local.x * col_count + icon_anchor_local.y
			new_item._snap_to(grid_array[calculated_grid_id].global_position)

			# Update slot states
			new_item.grid_anchor = slot
			for grid in new_item.item_grids:
				var grid_to_check = slot.slot_ID + grid[0] + grid[1] * col_count
				grid_array[grid_to_check].state = grid_array[grid_to_check].States.TAKEN
				grid_array[grid_to_check].item_stored = new_item
			
			item_held.z_index = 0
			
			item_held = null  # Clear temporary state
			return true  # Successfully placed

	# If no space found → remove the item we added
	new_item.queue_free()
	item_held = null
	return false

func clear_inventory() -> void:
	# Free all stored items inside the grid
	for slot in grid_array:
		if slot.item_stored:
			slot.item_stored.queue_free()
			slot.item_stored = null
		slot.state = slot.States.FREE
		slot.set_color(slot.States.DEFAULT)

	# Reset variables
	item_held = null
	current_slot = null
	can_place = false
	icon_anchor = Vector2.ZERO


func _on_item_picked_up(item: Variant) -> void:
	item.selected = true
	item_held = item


func _on_item_placed(item: Variant) -> void:
	item.selected = false
	item_held = null
