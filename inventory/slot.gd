extends TextureRect

signal slot_entered(slot)
signal slot_exited(slot)

@onready var filter = $statusFilter

var slot_ID
