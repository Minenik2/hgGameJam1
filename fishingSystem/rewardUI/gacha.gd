extends Node

# preload fish data
var greyscale: FishData = preload("res://fishingSystem/fishData/common/greyscale_marrow.tres")
var dustfin: FishData = preload("res://fishingSystem/fishData/common/dustfin.tres")
var pipe_darter: FishData = preload("res://fishingSystem/fishData/common/pipe_darter.tres")
var eyefish: FishData = preload("res://fishingSystem/fishData/common/eyefish.tres")
# rare
const EEL = preload("uid://dq10bv06wnmx8")
const HOODWINKER = preload("uid://bv4inqkcd5xmv")
const PELICAN = preload("uid://cjody3ulnnwxg")
const RHINOCHIMERA = preload("uid://bi0x4wx7in47b")
const SEAHORSE = preload("uid://bofyywxsj45ej")
# legendary
const FANG = preload("uid://csir7h22jg48o")
const GLOBB = preload("uid://dtxm6prtsie60")
const SCISSOR = preload("uid://d2ghws76xt4vf")
const STAR = preload("uid://rwsu00mccy8q")
const SWORDFISH = preload("uid://beull7eh4qrkf")
const TWINS = preload("uid://dephx8bnujd0w")

# seals
const SEAL_FRAG_1 = preload("uid://dlcebciiqqxno")
const SEAL_FRAG_2 = preload("uid://cshye4j7yh0ek")
const SEAL_FRAG_3 = preload("uid://dmi85s80seyn3")

# Pity counters
var rare_pity_counter = 1
var legendary_pity_counter = 1
var total_pulls = 0

#drops - item
var loot_table = {
	"common": [
		greyscale,
		dustfin,
		pipe_darter,
		eyefish
	],
	"rare": [
		EEL,
		HOODWINKER,
		PELICAN,
		RHINOCHIMERA,
		SEAHORSE
	],
	"legendary": [
		FANG,
		GLOBB,
		SCISSOR,
		STAR,
		SWORDFISH,
		TWINS
	]
}


var pull_rates = {
	"legendary": 0.6,    # 0.6%
	"rare": 5.1,   # 5.1%
	"common": 94.3    # 94.3%
}

func roll_loot():
	if total_pulls == 12:
		total_pulls += 1
		DialogueDisplay.state["foundFragment1"] = true
		return SEAL_FRAG_1
	elif total_pulls >= 24 and !DialogueDisplay.state["foundFragment2"] and DialogueDisplay.state["solvedFragment1"]:
		total_pulls += 1
		DialogueDisplay.state["foundFragment2"] = true
		return SEAL_FRAG_2
	elif total_pulls >= 36 and !DialogueDisplay.state["foundFragment3"] and DialogueDisplay.state["solvedFragment2"]:
		DialogueDisplay.state["foundFragment3"] = true
		return SEAL_FRAG_3
	
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
	
	total_pulls += 1
	
	return drop
