extends VBoxContainer

var quest_stage = 0
var itemsPlaced = []

func _on_give_item_pressed() -> void:
	AudioManager.playMenuClick()

	# shorthand for the player's inventory
	var inventory = %inventoryQuest.itemArray

	if inventory.is_empty():
		$tooltip.text = "Morgan! Stop daydreaming and give me the item"
		return

	# Only allow one item
	if inventory.size() > 1:
		$tooltip.text = "Morgan, only one item at a time"
		return

	var item = inventory[0]
	var currentQuest = QuestManager.get_active_quest("The Seal")

	# 1. Check if item matches what Sitri wants
	if item.fishData.name == currentQuest.required_item_name:
		if !currentQuest.dialogue_state_true.is_empty():
			for stateString in currentQuest.dialogue_state_true:
				DialogueDisplay.state[stateString] = true
		QuestManager.complete_quest_stage(currentQuest)
		DialogueDisplay.state["showRitualChoice"] = !DialogueDisplay.state["showRitualChoice"]

		# Clear inventory
		inventory.clear()
		%inventoryQuest.clear_inventory()
		$tooltip.text = "You gave Sitri the " + item.fishData.name
	else:
		$tooltip.text = "Morgan? This is not what I asked for"

# quest item placed in inventory
func _on_quest_item_placed(item: Variant) -> void:
	itemsPlaced.append(item)

func _on_quest_item_picked_up(item: Variant) -> void:
	itemsPlaced.erase(item)
