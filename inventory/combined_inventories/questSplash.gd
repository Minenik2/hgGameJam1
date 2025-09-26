extends VBoxContainer

var keyItemsGiven = 0
var itemsPlaced = []

var fragments = ["givenFragment1", "givenFragment2", "givenFragment3"]

func _on_give_item_pressed() -> void:
	AudioManager.playMenuClick()
	if %inventoryQuest.itemArray.is_empty():
		$tooltip.text = "Morgan! Stop daydreaming and give me the item"
	elif %inventoryQuest.itemArray.fishData.item_type == FishData.TYPE.KEYITEM and %inventoryQuest.itemArray.size() < 2:
		DialogueDisplay.state[fragments[keyItemsGiven]] = true
		keyItemsGiven += 1
		%inventoryQuest.itemArray.clear()
		$tooltip.text = "You gave Sitri the item"
		%inventoryQuest.clear_inventory()
	else:
		$tooltip.text = "Morgan? This is not what I asked for"

# quest item placed in inventory
func _on_quest_item_placed(item: Variant) -> void:
	itemsPlaced.append(item)

func _on_quest_item_picked_up(item: Variant) -> void:
	itemsPlaced.erase(item)
