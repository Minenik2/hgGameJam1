extends Sprite3D

@export var player: CharacterBody3D # player to look at

func _process(delta):
	if player:
		look_at(player.global_transform.origin, Vector3.UP)
