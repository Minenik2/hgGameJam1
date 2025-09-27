extends CanvasLayer

@onready var shader_mat := $TextureRect.material as ShaderMaterial

@onready var blur_mat := $blur.material as ShaderMaterial

func _ready():
	blur_mat.set_shader_parameter("blur_amount", 6.0)
	await get_tree().create_timer(0.2).timeout  # Optional delay
	var tween = create_tween()
	tween.tween_property(blur_mat, "shader_parameter/blur_amount", 0.0, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _process(_delta):
	var mouse_pos = get_viewport().get_mouse_position()
	var viewport_size = get_viewport().get_visible_rect().size

	shader_mat.set_shader_parameter("mouse_pos", mouse_pos)
	shader_mat.set_shader_parameter("viewport_size", viewport_size)
	shader_mat.set_shader_parameter("time", Time.get_ticks_msec() / 1000.0)

func _on_button_pressed() -> void:
	AudioManager.playMenuClick()
	var tween = create_tween()
	var timetween = 1.5
	tween.tween_property(blur_mat, "shader_parameter/blur_amount", 6, timetween).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	var path = "res://models/nested/3d_enviroment.tscn"
	ResourceLoader.load_threaded_request(path)

	while ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		await get_tree().process_frame

	var scene = ResourceLoader.load_threaded_get(path)
	get_tree().change_scene_to_packed(scene)
	
