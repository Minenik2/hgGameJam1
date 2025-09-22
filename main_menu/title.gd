extends Label

@export var glitch_interval := 0.05
@export var glitch_duration := 0.2
@export var glitch_intensity := 2.0  # pixel shake range

var original_text: String
var glitch_timer := 0.0
var is_glitching := false

func _ready():
	original_text = text
	glitch_timer = glitch_interval
	set_process(true)

func _process(delta):
	glitch_timer -= delta
	if glitch_timer <= 0:
		if is_glitching:
			text = original_text
			modulate = Color.WHITE
			position = Vector2.ZERO
			glitch_timer = glitch_interval
		else:
			text = glitch_text(original_text)
			modulate = Color(1, 1, 1, randf_range(0.6, 1.0))
			position = Vector2(
				randf_range(-glitch_intensity, glitch_intensity),
				randf_range(-glitch_intensity, glitch_intensity)
			)
			glitch_timer = glitch_duration
		is_glitching = !is_glitching

func glitch_text(original: String) -> String:
	var result := ""
	for c in original:
		if randf() < 0.2 and c != " ":
			result += char(randi_range(33, 126))  # Correct usage of char()
		else:
			result += c
	return result
