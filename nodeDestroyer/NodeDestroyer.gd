extends Node

# Dictionary that stores destroyed node paths
var destroyed_nodes: Dictionary = {}

func is_destroyed(node: Node) -> bool:
	return destroyed_nodes.get(node.get_path(), false)

func mark_destroyed(node: Node) -> void:
	destroyed_nodes[node.get_path()] = true
