extends Resource
class_name FishData

enum RARITY {
	COMMON,
	RARE,
	LEGENDARY
}

@export var name: String
@export var base_dimension: float
@export var dimension_variance: float = 0.5

@export var base_weight: float
@export var weight_variance: float = 0.5

@export var base_price: int
@export var price_variance: int = 20

@export var rarity: RARITY = RARITY.COMMON
@export var texture: Texture2D
@export var description: String

func generate_instance() -> Dictionary:
	var rng = RandomNumberGenerator.new()

	var dimension = base_dimension + rng.randf_range(-dimension_variance, dimension_variance)
	var weight = base_weight + rng.randf_range(-weight_variance, weight_variance)
	var price = base_price + rng.randi_range(-price_variance, price_variance)
	
	weight = abs(weight)
	dimension = abs(dimension)
	
	if weight < 0.01: weight = 0.01
	if dimension < 0.01: dimension = 0.01

	return {
		"name": name,
		"dimension": dimension,
		"weight": weight,
		"price": price,
		"rarity": rarity,
		"texture": texture,
		"description": description
	}
