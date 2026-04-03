extends Node2D

signal died(snake)

var segments = []
var _direction = Vector2.RIGHT
var _current_angle = 0.0
var _target_angle = 0.0
var _speed = GameManager.INITIAL_SPEED
var _is_boosting = false
var _segment_radius = GameManager.SNAKE_SEGMENT_RADIUS
var _segment_gap = GameManager.SNAKE_SEGMENT_GAP
var _is_alive = true
var _is_player = false
var _base_color = Color(0.3, 0.8, 0.3)


func setup(pos, color, is_player):
	_is_player = is_player
	_base_color = color
	position = Vector2.ZERO
	_init_segments(pos)


func _init_segments(start_pos):
	segments.clear()
	for i in range(GameManager.INITIAL_LENGTH):
		segments.append(start_pos - Vector2(float(i) * _segment_gap, 0.0))


func set_direction(dir):
	if dir == Vector2.ZERO:
		return
	_target_angle = dir.angle()


func set_boost(active):
	_is_boosting = active


func _process(delta):
	if not _is_alive:
		return
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return

	# Smooth rotation
	var angle_diff = _target_angle - _current_angle
	while angle_diff > PI:
		angle_diff -= 2.0 * PI
	while angle_diff < -PI:
		angle_diff += 2.0 * PI

	_current_angle += angle_diff * minf(8.0 * delta, 1.0)
	_direction = Vector2.from_angle(_current_angle)

	# Speed
	var speed = _speed
	if _is_boosting and segments.size() > 5:
		speed = GameManager.BOOST_SPEED
		if Engine.get_frames_drawn() % 6 == 0 and segments.size() > 3:
			var removed_pos = segments[-1]
			segments.pop_back()
			if get_parent() and get_parent().has_method("_spawn_food_at"):
				get_parent()._spawn_food_at(removed_pos)

	# Move head
	var new_head = segments[0] + _direction * speed * delta
	new_head = GameManager.clamp_to_map(new_head)

	# Boundary death
	var r = _segment_radius
	if new_head.x <= r or new_head.x >= GameManager.MAP_WIDTH - r:
		_die()
		return
	if new_head.y <= r or new_head.y >= GameManager.MAP_HEIGHT - r:
		_die()
		return

	# Update segments
	segments[0] = new_head
	for i in range(1, segments.size()):
		var target = segments[i - 1]
		var current = segments[i]
		var dist = current.distance_to(target)
		if dist > _segment_gap:
			segments[i] = current + (target - current).normalized() * (dist - _segment_gap)

	if _is_player:
		GameManager.set_length(segments.size())

	queue_redraw()


func grow(amount = 1):
	for i in range(amount):
		segments.append(segments[-1])


func _die():
	if not _is_alive:
		return
	_is_alive = false
	died.emit(self)
	queue_redraw()


func get_head_position():
	if segments.is_empty():
		return Vector2.ZERO
	return segments[0]


func get_body_positions():
	if segments.size() <= 1:
		return []
	return segments.slice(1)


func get_length():
	return segments.size()


func is_alive():
	return _is_alive


func reset(pos):
	_is_alive = true
	_is_boosting = false
	_current_angle = randf() * TAU
	_target_angle = _current_angle
	_direction = Vector2.from_angle(_current_angle)
	_init_segments(pos)
	queue_redraw()


func _draw():
	if not _is_alive:
		return
	if segments.is_empty():
		return

	# Body (back to front)
	for i in range(segments.size() - 1, -1, -1):
		var seg = segments[i]
		var t = float(i) / float(maxi(segments.size() - 1, 1))

		var radius = _segment_radius
		var c

		if i == 0:
			# Head - bigger, brighter
			radius = _segment_radius * 1.3
			if _is_boosting:
				c = Color(1.0, 1.0, 0.4)
			else:
				c = Color(minf(_base_color.r * 1.4, 1.0), minf(_base_color.g * 1.4, 1.0), minf(_base_color.b * 1.4, 1.0))
		elif i == segments.size() - 1 and segments.size() > 3:
			# Tail - smaller
			radius = _segment_radius * 0.7
			c = Color(_base_color.r * 0.5, _base_color.g * 0.5, _base_color.b * 0.5)
		else:
			# Body gradient
			var fade = 1.0 - t * 0.35
			c = Color(_base_color.r * fade, _base_color.g * fade, _base_color.b * fade)

		draw_circle(seg, radius, c)

	# Eyes
	if segments.size() > 0 and _is_alive:
		var head = segments[0]
		var eye_off = _segment_radius * 0.45
		var perp = Vector2(-_direction.y, _direction.x)
		var eye1 = head + _direction * eye_off + perp * eye_off * 0.5
		var eye2 = head + _direction * eye_off - perp * eye_off * 0.5
		draw_circle(eye1, _segment_radius * 0.25, Color.WHITE)
		draw_circle(eye2, _segment_radius * 0.25, Color.WHITE)
		draw_circle(eye1 + _direction * 1.2, _segment_radius * 0.12, Color.BLACK)
		draw_circle(eye2 + _direction * 1.2, _segment_radius * 0.12, Color.BLACK)
