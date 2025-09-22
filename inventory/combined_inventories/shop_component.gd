extends VBoxContainer

@onready var total_cost_ui: Label = $MarginContainer2/totalCost
@onready var inventory_shop: Control = $inventoryShop

var totalCost = 0

func _on_inventory_shop_item_placed(item: Variant) -> void:
	# when the player places an item in the shop inventory
	totalCost += item.fishData.fishDataDict["price"]
	updateVisual()

func _on_inventory_shop_item_picked_up(item: Variant) -> void:
	totalCost -= item.fishData.fishDataDict["price"]
	updateVisual()

func _on_sell_pressed() -> void:
	if totalCost > 0:
		AudioManager.playShopSell()
	else:
		AudioManager.playMenuClick()
	Database.money += totalCost
	totalCost = 0
	updateVisual()
	inventory_shop.clear_inventory()

func updateVisual():
	total_cost_ui.text = "Total IKO: " + str(Database.money) + "\n" + "Current IKO: " + str(totalCost)
	
