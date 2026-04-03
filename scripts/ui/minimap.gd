extends Control

var _player_ref = null
var _snakes = []
var _foods = []


func update_data(player, snakes, foods):
	_player_ref = player
	_snakes = snakes
	_foods = foods
	queue_redraw()


func _draw():
	var size = custom_minimum_size
	if size.x <= 0:
		size = Vector2(120, 120)
		custom_minimum_size = size

	var mw = GameManager.MAP_WIDTH
	var mh = GameManager.MAP_HEIGHT

	# Background
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.0, 0.0, 0.0, 0.6))
	draw_rect(Rect2(Vector2.ZERO, size), Color(1.0, 1.0, 1.0, 0.3), false, 1.0)

	# Food
	for food in _foods:
		if not is_instance_valid(food):
			continue
		var fx = food.position.x / mw * size.x
		var fy = food.position.y / mh * size.y
		draw_rect(Rect2(Vector2(fx, fy), Vector2(1, 1)), Color(0.5, 0.5, 0.5, 0.4))

	# AI snakes
	for s in _snakes:
		if not is_instance_valid(s) or s == _player_ref:
			continue
		if s and s.is_alive():
			var p = s.get_head_position()
			draw_circle(Vector2(p.x / mw * size.x, p.y / mh * size.y), 2.0, Color.RED)

	# Player
	if _player_ref and is_instance_valid(_player_ref) and _player_ref.is_alive():
		var p = _player_ref.get_head_position()
		draw_circle(Vector2(p.x / mw * size.x, p.y / mh * size.y), 3.0, Color.GREEN)
