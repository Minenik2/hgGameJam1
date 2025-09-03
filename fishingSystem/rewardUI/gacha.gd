extends Node

# preload fish data
var greyscale: FishData = preload("res://fishingSystem/fishData/common/greyscale_marrow.tres")
var dustfin: FishData = preload("res://fishingSystem/fishData/common/dustfin.tres")
var pipe_darter: FishData = preload("res://fishingSystem/fishData/common/pipe_darter.tres")

# Pity counters
var rare_pity_counter = 1
var legendary_pity_counter = 1

#drops - item
var loot_table = {
	"common": [
		greyscale,
		dustfin,
		pipe_darter
	],
	"rare": [
		greyscale
		# TODO ADD MORE
	],
	"legendary": [
		dustfin
		# TODO ADD MORE
	]
}


var pull_rates = {
	"legendary": 0.6,    # 0.6%
	"rare": 5.1,   # 5.1%
	"common": 94.3    # 94.3%
}

func roll_loot():
	var roll = randf_range(0, 100)
	var rarity = ""
	
	rare_pity_counter += 1
	legendary_pity_counter += 1

	# Determine rarity by cumulative probability ranges
	if roll < pull_rates["legendary"] or legendary_pity_counter >= 60:
		rarity = "legendary"
		legendary_pity_counter = 0
	elif roll < pull_rates["legendary"] + pull_rates["rare"] or rare_pity_counter >= 10:
		rarity = "rare"
		rare_pity_counter = 0
	else:
		rarity = "common"
		

	# Shuffle and pick a drop from the chosen pool
	loot_table[rarity].shuffle()
	var drop = loot_table[rarity][0]
	
	return drop
