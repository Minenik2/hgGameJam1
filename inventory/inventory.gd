extends Node

# --- Grid Settings ---
@export var GRID_WIDTH: int = 10   # number of slots horizontally
@export var GRID_HEIGHT: int = 6   # number of slots vertically
@export var slot_size: int = 48    # size of each inventory slot in pixels

# 2D array to hold items in the grid
var grid := []

# Container to hold UI elements for the grid
@onready var grid_container: Control = $GridContainer

func _ready():
	# Initialize the grid
	grid.resize(GRID_HEIGHT)
	for y in range(GRID_HEIGHT):
		grid[y] = []
		grid[y].resize(GRID_WIDTH)
		for x in range(GRID_WIDTH):
			grid[y][x] = null
	
	var sword = Item.new()
	sword.name = "Sword"
	sword.icon = preload("res://art/fish/bigf.png")
	sword.shape = [[1], [2]]

	draw_item(sword, Vector2(0,0))  # Draw at top-left corner

func can_place_item(item: Item, pos: Vector2) -> bool:
	var h = item.shape.size()
	var w = item.shape[0].size()
	for y in range(h):
		for x in range(w):
			if item.shape[y][x]:
				var gx = pos.x + x
				var gy = pos.y + y
				if gx >= GRID_WIDTH or gy >= GRID_HEIGHT or grid[gy][gx] != null:
					return false
	return true

func place_item(item: Item, pos: Vector2) -> bool:
	if not can_place_item(item, pos):
		return false
	var h = item.shape.size()
	var w = item.shape[0].size()
	for y in range(h):
		for x in range(w):
			if item.shape[y][x]:
				grid[pos.y + y][pos.x + x] = item
	return true

func remove_item(item: Item) -> void:
	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			if grid[y][x] == item:
				grid[y][x] = null

func draw_item(item: Item, pos: Vector2):
	var h = item.shape.size()
	var w = item.shape[0].size()
	for y in range(h):
		for x in range(w):
			if item.shape[y][x]:
				var slot_pos = pos + Vector2(x, y) * slot_size
				var icon_rect = TextureRect.new()
				icon_rect.texture = item.icon
				icon_rect.rect_position = slot_pos
				icon_rect.rect_size = Vector2(slot_size, slot_size)
				grid_container.add_child(icon_rect)
