extends Label



func _on_inventory_reward_item_picked_up(item: Variant) -> void:
	text = "IKO Held: " + str(item.fishData.fishDataDict["price"])


func _on_inventory_reward_item_placed(item: Variant) -> void:
	text = "IKO Held: 0"
