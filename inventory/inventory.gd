extends Control

@onready var slot_scene = preload("res://inventory/slot.tscn")
@onready var grid_container: GridContainer = $VBoxContainer/ScrollContainer/GridContainer
@onready var item_scene = preload("res://inventory/item.tscn")
@onready var scroll_container = $VBoxContainer/ScrollContainer
@onready var col_count = grid_container.columns

var grid_array := []
var item_held = null
var current_slot = null
var can_place := false
var icon_anchor : Vector2

func _ready() -> void:
	for i in range(64):
		create_slot()
	await get_tree().process_frame
	spawn_item_to_inventory(1)
	spawn_item_to_inventory(1)

func _process(delta: float) -> void:
	if item_held:
		if Input.is_action_just_pressed("rotate"):
			rotate_item()
			
		if Input.is_action_just_pressed("interact"):
			if scroll_container.get_global_rect().has_point(get_global_mouse_position()):
				place_item()
	else:
		if Input.is_action_just_pressed("interact"):
			if scroll_container.get_global_rect().has_point(get_global_mouse_position()):
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


func _on_button_spawn_pressed() -> void:
	var new_item = item_scene.instantiate()
	$"../..".add_child(new_item)
	new_item.load_item(1)
	new_item.selected = true
	item_held = new_item

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
	
	item_held = null
	clear_grid()

func pick_item():
	if not current_slot or not current_slot.item_stored:
		return
	
	item_held = current_slot.item_stored
	item_held.selected = true
	
	item_held.get_parent().remove_child(item_held)
	add_child(item_held)
	item_held.global_position = get_global_mouse_position()
	
	for grid in item_held.item_grids:
		var grid_to_check = item_held.grid_anchor.slot_ID + grid[0] + grid[1] * col_count
		grid_array[grid_to_check].state = grid_array[grid_to_check].States.FREE
		grid_array[grid_to_check].item_stored = null
	
	check_slot_availability(current_slot)
	set_grids.call_deferred(current_slot) 

func spawn_item_to_inventory(item_id: int) -> bool:
	# 1. Create and add to scene tree before anything else
	var new_item = item_scene.instantiate()
	grid_container.add_child(new_item)
	
	# 2. Load item data (now safe since it's in the tree)
	new_item.load_item(item_id)

	# 3. Try to find a slot where the item can fit
	for slot in grid_array:
		item_held = new_item  # Temporarily assign so check_slot_availability works
		check_slot_availability(slot)

		if can_place:
			for grid in item_held.item_grids:
				if grid[1] < icon_anchor.x: icon_anchor.x = grid[1]
				if grid[0] < icon_anchor.y: icon_anchor.y = grid[0]
			
			var calculated_grid_id = slot.slot_ID + icon_anchor.x * col_count + icon_anchor.y
			print(grid_array[calculated_grid_id].global_position)
			var destination = grid_array[calculated_grid_id].global_position
			if int(rotation_degrees) % 100 == 0:
				destination += new_item.iconRect_path.size
			else:
				var temp_xy_switch = Vector2(new_item.iconRect_path.size.y, new_item.iconRect_path.size.x)
				destination += temp_xy_switch
			new_item.global_position = destination

			# Update slot states
			new_item.grid_anchor = slot
			for grid in new_item.item_grids:
				var grid_to_check = slot.slot_ID + grid[0] + grid[1] * col_count
				grid_array[grid_to_check].state = grid_array[grid_to_check].States.TAKEN
				grid_array[grid_to_check].item_stored = new_item

			item_held = null  # Clear temporary state
			return true  # Successfully placed

	# If no space found → remove the item we added
	new_item.queue_free()
	item_held = null
	return false
