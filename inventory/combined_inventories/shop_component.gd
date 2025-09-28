extends VBoxContainer

@onready var total_cost_ui: Label = $MarginContainer2/totalCost
@onready var inventory_shop: Control = $inventoryShop

var pulse_tween: Tween
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
	if totalCost > 0:
		$MarginContainer/sell.add_theme_color_override("font_color", Color(0.833, 1.0, 0.0, 1.0))
		start_pulse($MarginContainer/sell)
	else:
		$MarginContainer/sell.add_theme_color_override("font_color", Color(1, 1, 1, 1.0))
		stop_pulse()
		$MarginContainer/sell.scale = Vector2(1, 1)
	
func start_pulse(button: Button):
	# set pivot so it scales from center
	button.pivot_offset = button.size / 2  

	# kill old tween if already running
	if pulse_tween and pulse_tween.is_running():
		pulse_tween.kill()

	pulse_tween = create_tween()
	pulse_tween.set_loops() # infinite loop

	# Scale up
	pulse_tween.tween_property(button, "scale", Vector2(1.2, 1.2), 0.3)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	# Scale down
	pulse_tween.tween_property(button, "scale", Vector2(1, 1), 0.3)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)


func stop_pulse():
	if pulse_tween and pulse_tween.is_running():
		pulse_tween.kill()
		pulse_tween = null
