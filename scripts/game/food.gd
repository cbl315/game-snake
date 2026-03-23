extends Node2D

const FOOD_SCORE = 10

var _sprite
var _grid_position = Vector2.ZERO


func _ready():
	_create_sprite()
	randomize_position()


func _create_sprite():
	_sprite = Sprite2D.new()
	_sprite.texture = _create_food_texture()
	_sprite.modulate = Color.RED
	add_child(_sprite)


func _create_food_texture():
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


func randomize_position(snake_body = []):
	var valid_positions = []

	for x in range(GameManager.grid_width):
		for y in range(GameManager.grid_height):
			var pos = Vector2(float(x), float(y))
			if pos not in snake_body:
				valid_positions.append(pos)

	if valid_positions.is_empty():
		push_error("No valid positions for food!")
		return

	_grid_position = valid_positions.pick_random()
	_update_position()


func _update_position():
	position = GameManager.grid_to_world(_grid_position)


func get_grid_position():
	return _grid_position


func check_collision(head_pos):
	return head_pos == _grid_position
