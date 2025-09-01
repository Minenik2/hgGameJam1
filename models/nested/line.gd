extends MeshInstance3D

@export var rod_tip: Node3D
@export var hook: Node3D

func _process(delta: float) -> void:
	if rod_tip == null or hook == null:
		return
	
	# Get global positions
	var start: Vector3 = rod_tip.global_transform.origin
	var end: Vector3 = hook.global_transform.origin
	
	# Set line position to midpoint
	global_transform.origin = (start + end) * 0.5
	
	# Calculate direction and length
	var dir: Vector3 = (end - start)
	var dist: float = dir.length()
	
	# Scale cylinder to the right length
	scale = Vector3(0.02, dist * 0.5, 0.02) # X,Z = thickness, Y = half length
	
	# Rotate so Y axis points along the direction
	look_at(end, Vector3.UP)
	rotate_object_local(Vector3.RIGHT, deg_to_rad(90)) # align cylinder's Y axis
