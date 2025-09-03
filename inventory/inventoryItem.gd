extends Resource
class_name Item

@export var id: String
@export var name: String
@export var icon: Texture
@export var shape: Array = [[true]]  # 2D array: true = occupied, false = empty

var rotated := false

func rotate():
	# Rotate 90° clockwise
	rotated = !rotated
	var new_shape := []
	var h = shape.size()
	var w = shape[0].size()
	for x in range(w):
		var new_row := []
		for y in range(h - 1, -1, -1):
			new_row.append(shape[y][x])
		new_shape.append(new_row)
	shape = new_shape
