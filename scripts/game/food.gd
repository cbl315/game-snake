extends Node2D

enum FoodType { APPLE, CHERRY, STAR, SPEED }

const FOOD_CONFIGS = {
	FoodType.APPLE: {"score": 10, "grow": 1, "color": Color.RED, "radius": 5.0, "weight": 50},
	FoodType.CHERRY: {"score": 20, "grow": 2, "color": Color(1.0, 0.4, 0.6), "radius": 6.0, "weight": 25},
	FoodType.STAR: {"score": 50, "grow": 3, "color": Color(1.0, 0.85, 0.0), "radius": 7.0, "weight": 10},
	FoodType.SPEED: {"score": 5, "grow": 1, "color": Color(0.3, 0.6, 1.0), "radius": 5.0, "weight": 15},
}

var _food_type = FoodType.APPLE
var _pulse_timer = 0.0


func setup(pos, food_type = -1):
	if food_type >= 0:
		_food_type = food_type
	else:
		_randomize_type()
	position = pos


func _randomize_type():
	var total = 0
	for ft in FOOD_CONFIGS:
		total += FOOD_CONFIGS[ft]["weight"]
	var roll = randi() % total
	var cum = 0
	for ft in FOOD_CONFIGS:
		cum += FOOD_CONFIGS[ft]["weight"]
		if roll < cum:
			_food_type = ft
			return


func get_score():
	return FOOD_CONFIGS[_food_type]["score"]


func get_grow_amount():
	return FOOD_CONFIGS[_food_type]["grow"]


func get_radius():
	return FOOD_CONFIGS[_food_type]["radius"]


func check_collision(head_pos, head_radius):
	return head_pos.distance_to(position) < head_radius + get_radius()


func _process(delta):
	_pulse_timer += delta * 3.0
	queue_redraw()


func _draw():
	var config = FOOD_CONFIGS[_food_type]
	var r = config["radius"] + sin(_pulse_timer) * 1.5
	# Glow
	draw_circle(Vector2.ZERO, r + 3.0, Color(config["color"].r, config["color"].g, config["color"].b, 0.25))
	# Main
	draw_circle(Vector2.ZERO, r, config["color"])
