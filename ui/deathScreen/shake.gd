extends Label

var shake_amount: float = 3.0
var shaking: bool = true

func _process(delta: float) -> void:
	if shaking:
		# Random small offset
		position.x = randf_range(-shake_amount, shake_amount)
		position.y = randf_range(-shake_amount, shake_amount)
	else:
		# Reset to default position
		position = Vector2.ZERO
