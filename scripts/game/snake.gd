extends Node2D

signal food_eaten
signal collision_detected

const DIRECTION_MAP = {
	Vector2.UP: 0.0,
	Vector2.RIGHT: 90.0,
	Vector2.DOWN: 180.0,
	Vector2.LEFT: 270.0
}

var _direction = Vector2.RIGHT
var _next_direction = Vector2.RIGHT
var _body_segments = []
var _move_timer = 0.0
var _current_speed

@onready var _head = $Head
@onready var _body_container = $BodySegments


func _ready():
	_current_speed = GameManager.INITIAL_SPEED
	_initialize_snake()
	TouchInput.swipe_detected.connect(_on_swipe_detected)


func _initialize_snake():
	var start_pos = Vector2(
		float(GameManager.grid_width) / 2.0,
		float(GameManager.grid_height) / 2.0
	)

	_body_segments.clear()
	_body_segments.append(start_pos)
	_body_segments.append(start_pos + Vector2.LEFT)
	_body_segments.append(start_pos + Vector2.LEFT * 2.0)

	_update_visuals()


func _process(delta):
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return

	_move_timer += delta

	if _move_timer >= _current_speed:
		_move_timer = 0.0
		_move_snake()


func _move_snake():
	if _next_direction != -_direction:
		_direction = _next_direction

	var new_head_pos = _body_segments[0] + _direction

	if _check_wall_collision(new_head_pos):
		collision_detected.emit()
		return

	if _check_self_collision(new_head_pos):
		collision_detected.emit()
		return

	_body_segments.push_front(new_head_pos)
	_body_segments.pop_back()
	_update_visuals()


func _check_wall_collision(pos):
	return pos.x < 0.0 or pos.x >= float(GameManager.grid_width) or pos.y < 0.0 or pos.y >= float(GameManager.grid_height)


func _check_self_collision(pos):
	return pos in _body_segments


func grow():
	var tail_pos = _body_segments[-1]
	_body_segments.append(tail_pos)
	_current_speed = maxf(GameManager.MIN_SPEED, _current_speed - GameManager.SPEED_INCREMENT)
	_update_visuals()


func set_direction(new_direction):
	if new_direction != -_direction:
		_next_direction = new_direction


func _on_swipe_detected(direction):
	set_direction(direction)


func _update_visuals():
	if _body_segments.is_empty():
		return

	var head_grid_pos = _body_segments[0]
	_head.position = GameManager.grid_to_world(head_grid_pos)
	_head.rotation_degrees = DIRECTION_MAP.get(_direction, 0.0)

	for child in _body_container.get_children():
		child.queue_free()

	for i in range(1, _body_segments.size()):
		var segment_pos = _body_segments[i]
		var body_sprite = _create_body_segment(segment_pos, i)
		_body_container.add_child(body_sprite)


func _create_body_segment(grid_pos, index):
	var sprite = Sprite2D.new()
	sprite.texture = _create_circle_texture()
	sprite.position = GameManager.grid_to_world(grid_pos)
	sprite.modulate = Color(0.3, 0.7, 0.3)
	return sprite


func _create_circle_texture():
	var size = GameManager.GRID_SIZE - 4
	var image = Image.create(size, size, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)

	var center = Vector2.ONE * (size / 2.0)
	var radius = (size / 2.0) - 1.0

	for x in range(size):
		for y in range(size):
			var dist = Vector2(float(x), float(y)).distance_to(center)
			if dist <= radius:
				image.set_pixel(x, y, Color.WHITE)

	return ImageTexture.create_from_image(image)


func get_head_position():
	if _body_segments.is_empty():
		return Vector2.ZERO
	return _body_segments[0]


func get_body_segments():
	return _body_segments.duplicate()


func reset():
	_direction = Vector2.RIGHT
	_next_direction = Vector2.RIGHT
	_current_speed = GameManager.INITIAL_SPEED
	_move_timer = 0.0
	_initialize_snake()
