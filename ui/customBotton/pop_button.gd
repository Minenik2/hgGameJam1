extends Button

@export var hover_scale: float = 1.2
@export var tween_time: float = 0.15
@export var transition: Tween.TransitionType = Tween.TRANS_SINE
@export var ease_type: Tween.EaseType = Tween.EASE_OUT

var original_scale: Vector2
var current_tween: Tween = null

func _ready() -> void:
	# Make sure scaling pivots from the center
	
	original_scale = scale
	
	# Connect hover signals
	mouse_entered.connect(_on_mouse_entered)
	
	call_deferred("_init_pivot")

func _init_pivot():
	pivot_offset = size/2.0

func _on_mouse_entered() -> void:
	_tween_to(original_scale * hover_scale)
	AudioManager.playMenuHover()

func _tween_to(target_scale: Vector2) -> void:
	if current_tween:
		current_tween.kill()
	current_tween = create_tween()
	current_tween.tween_property(self, "scale", target_scale, tween_time) \
				 .set_trans(transition) \
				 .set_ease(ease_type)
