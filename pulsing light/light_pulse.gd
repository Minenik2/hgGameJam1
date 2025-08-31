extends OmniLight3D

func _ready():
	pulse_light()

func pulse_light():
	var tween = create_tween().set_loops(-1) # infinite loop
	
	print(tween)

	# Animate energy up
	tween.tween_property(self, "light_energy", 40000.0, 15.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	# Animate energy down
	tween.tween_property(self, "light_energy", 20000.0, 15.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
