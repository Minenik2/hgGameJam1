extends Area3D

@onready var timer: Timer = $Timer

func _on_body_entered(body: Node3D) -> void:
	# todo death effect or something
	AudioManager.playDeath()
	DeathScreen.show()
	timer.start()


func _on_timer_timeout() -> void:
	get_tree().reload_current_scene()
	DeathScreen.hide()
