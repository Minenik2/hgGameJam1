extends Node

# Player stats
var money = 0

# chance for double fish
var doubleChance = 5 # %

# how long til the fish bites between
var wait_time_min = 3.0 # 1.0
var wait_time_max = 6.0 # 3.0

# upgrades
var costRod = 100
var costBait = 100
var costWire = 100

# increase cost
var increaseCost = 20

# upgrade level
var levelRod = 1
var levelBait = 1
var levelWire = 1
# max level
var levelMaxRod = 25
var levelMaxBait = 25
var levelMaxWire = 25

# increase
var increaseTime = 0.1
var increaseChance = 3
var increaseRarity = 1.2

# quests
var catchNeededForFragment1 = 12
var catchNeededForFragment2 = 24
var catchNeededForFragment3 = 36

# quests for fish identification
var lookingToSolveFragment1 = false
var lookingToSolveFragment2 = false
var lookingToSolveFragment3 = false

func round_to_decimals(value: float, decimals: int) -> float:
	var factor = pow(10, decimals)
	return round(value * factor) / factor

# upgrades buy functions
func buyRod():
	money -= costRod
	levelRod += 1
	wait_time_min = round_to_decimals(wait_time_min - increaseTime, 2)
	wait_time_max = round_to_decimals(wait_time_max - increaseTime, 2)
	costRod += increaseCost

func buyBait():
	money -= costBait
	levelBait += 1
	doubleChance += increaseChance
	costBait += increaseCost
	
func buyWire():
	money -= costWire
	levelWire += 1
	Gacha.pull_rates["rare"] = Gacha.pull_rates["rare"] + increaseRarity
	Gacha.pull_rates["legendary"] = Gacha.pull_rates["legendary"] + increaseRarity
	Gacha.pull_rates["common"] = 100 - (Gacha.pull_rates["rare"] + Gacha.pull_rates["legendary"])
	costWire += increaseCost

# TODO
# increaseRodPower less wait time
# increase chance for double fish
# chance for higher fish increase
# fish catalog
# some kind of monster chasing you , might take to long with ai coding, animation etc
