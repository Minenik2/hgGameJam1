extends MeshInstance3D

var rod_tip: Node3D
var bobber: Node3D
var radius: float = 0.3  # thickness of the line

func _process(_delta: float) -> void:
	if rod_tip == null or bobber == null or not is_instance_valid(bobber):
		visible = false
		return
	visible = true

	var start_pos: Vector3 = rod_tip.global_transform.origin
	var end_pos: Vector3 = bobber.get_node("LineAnchor").global_transform.origin
	var direction: Vector3 = end_pos - start_pos
	var dist: float = direction.length()
	if dist <= 0.0001:
		return

	var midpoint: Vector3 = (start_pos + end_pos) * 0.5

	# Make Y axis point along the direction (so Cylinder Y aligns with the line)
	var y_axis: Vector3 = direction.normalized()

	# pick a fallback 'arbitrary' vector that's not parallel to y_axis
	var arbitrary: Vector3 = Vector3.UP
	if abs(y_axis.dot(arbitrary)) > 0.99:
		arbitrary = Vector3.FORWARD

	var x_axis: Vector3 = arbitrary.cross(y_axis).normalized()
	var z_axis: Vector3 = y_axis.cross(x_axis).normalized()

	var new_basis: Basis = Basis(x_axis, y_axis, z_axis)

	# Apply transform & scale (Cylinder's Y is length axis; height = 1 -> scale by dist*0.5)
	global_transform = Transform3D(new_basis, midpoint)
	scale = Vector3(radius, dist * 10, radius)

func flash_red(total_duration := 0.5, loops := 3) -> void:
	if not mesh or not mesh is CylinderMesh:
		return
	
	var tween = create_tween()
	var half_flash_duration = total_duration / (loops * 2)  # each red/back counts as half

	for i in range(loops):
		tween.tween_property(mesh.material, "albedo_color", Color.RED, half_flash_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(mesh.material, "albedo_color", Color.WHITE, half_flash_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
