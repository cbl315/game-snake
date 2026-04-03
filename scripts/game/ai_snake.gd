extends Node

var snake  # Reference to the snake node
var game   # Reference to the game node
var _wander_angle = 0.0
var _wander_timer = 0.0
var _avoid_timer = 0.0


func _process(delta):
	if not snake or not is_instance_valid(snake) or not snake.is_alive():
		return
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return

	_wander_timer -= delta
	_avoid_timer -= delta

	var head = snake.get_head_position()

	# Avoid boundaries
	if _avoid_timer <= 0.0:
		var avoid = _check_boundaries(head)
		if avoid != Vector2.ZERO:
			snake.set_direction(avoid)
			_avoid_timer = 0.5
			return

	# Find nearest food
	var nearest = _find_nearest_food(head)
	if nearest != null:
		snake.set_direction((nearest - head).normalized())
	else:
		# Wander
		if _wander_timer <= 0.0:
			_wander_angle += randf_range(-0.8, 0.8)
			_wander_timer = randf_range(1.0, 3.0)
		snake.set_direction(Vector2.from_angle(_wander_angle))

	# Random boost
	snake.set_boost(randf() < 0.002 and snake.get_length() > 8)


func _check_boundaries(head):
	var margin = 100.0
	if head.x < margin:
		return Vector2.RIGHT
	if head.x > GameManager.MAP_WIDTH - margin:
		return Vector2.LEFT
	if head.y < margin:
		return Vector2.DOWN
	if head.y > GameManager.MAP_HEIGHT - margin:
		return Vector2.UP
	return Vector2.ZERO


func _find_nearest_food(head):
	if not game or not is_instance_valid(game):
		return null

	var nearest = null
	var min_dist = 400.0

	for food in game._foods:
		if not is_instance_valid(food):
			continue
		var d = head.distance_to(food.position)
		if d < min_dist:
			min_dist = d
			nearest = food.position

	return nearest
