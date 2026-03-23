extends Node2D

var _snake
var _food

@onready var _score_label = $HUD/MarginContainer/VBoxContainer/ScoreLabel
@onready var _high_score_label = $HUD/MarginContainer/VBoxContainer/HighScoreLabel

var _game_over_panel


func _ready():
	_setup_hud()
	_create_snake()
	_create_food()
	_connect_signals()
	GameManager.reset_game()
	_spawn_food()


func _setup_hud():
	_score_label.add_theme_font_size_override("font_size", 32)
	_score_label.add_theme_color_override("font_color", Color.WHITE)
	_high_score_label.add_theme_font_size_override("font_size", 24)
	_high_score_label.add_theme_color_override("font_color", Color.YELLOW)
	_high_score_label.text = "Best: " + str(GameManager.high_score)


func _create_snake():
	_snake = Node2D.new()
	_snake.name = "Snake"
	_snake.set_script(load("res://scripts/game/snake.gd"))

	var head = Sprite2D.new()
	head.name = "Head"
	head.texture = _create_circle_texture(GameManager.GRID_SIZE - 2)
	head.modulate = Color(0.2, 0.7, 0.2)
	_snake.add_child(head)

	var body_container = Node.new()
	body_container.name = "BodySegments"
	_snake.add_child(body_container)

	add_child(_snake)


func _create_food():
	_food = Node2D.new()
	_food.name = "Food"
	_food.set_script(load("res://scripts/game/food.gd"))
	add_child(_food)


func _create_circle_texture(size):
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


func _connect_signals():
	if _snake.has_signal("collision_detected"):
		_snake.collision_detected.connect(_on_snake_collision)
	GameManager.score_updated.connect(_on_score_updated)
	GameManager.high_score_updated.connect(_on_high_score_updated)


func _spawn_food():
	if _food and _food.has_method("randomize_position"):
		var snake_body = []
		if _snake.has_method("get_body_segments"):
			snake_body = _snake.get_body_segments()
		_food.randomize_position(snake_body)


func _process(_delta):
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return

	if _snake and _food:
		var head_pos = _snake.get_head_position()
		if _food.has_method("check_collision") and _food.check_collision(head_pos):
			_on_food_eaten()


func _on_food_eaten():
	GameManager.add_score(10)
	if _snake.has_method("grow"):
		_snake.grow()
	_spawn_food()


func _on_snake_collision():
	GameManager.change_state(GameManager.GameState.GAME_OVER)
	_show_game_over()


func _on_score_updated(new_score):
	_score_label.text = "Score: " + str(new_score)


func _on_high_score_updated(new_high_score):
	_high_score_label.text = "Best: " + str(new_high_score)


func _show_game_over():
	_game_over_panel = ColorRect.new()
	_game_over_panel.name = "GameOverPanel"
	_game_over_panel.color = Color(0.0, 0.0, 0.0, 0.7)
	_game_over_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	_game_over_panel.mouse_filter = Control.MOUSE_FILTER_STOP

	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.set_anchors_preset(Control.PRESET_CENTER)

	var game_over_label = Label.new()
	game_over_label.text = "GAME OVER"
	game_over_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	game_over_label.add_theme_font_size_override("font_size", 48)
	game_over_label.add_theme_color_override("font_color", Color.RED)
	vbox.add_child(game_over_label)

	var final_score = Label.new()
	final_score.text = "Score: " + str(GameManager.current_score)
	final_score.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	final_score.add_theme_font_size_override("font_size", 32)
	final_score.add_theme_color_override("font_color", Color.WHITE)
	vbox.add_child(final_score)

	var spacer = Control.new()
	spacer.custom_minimum_size.y = 40
	vbox.add_child(spacer)

	var restart_btn = Button.new()
	restart_btn.text = "Play Again"
	restart_btn.add_theme_font_size_override("font_size", 24)
	restart_btn.custom_minimum_size = Vector2(200, 60)
	restart_btn.pressed.connect(_on_restart_pressed)
	vbox.add_child(restart_btn)

	_game_over_panel.add_child(vbox)

	var hud = $HUD
	hud.add_child(_game_over_panel)


func _on_restart_pressed():
	if _game_over_panel:
		_game_over_panel.queue_free()
		_game_over_panel = null

	if _snake.has_method("reset"):
		_snake.reset()
	GameManager.reset_game()
	_spawn_food()


func _input(event):
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return

	var new_dir = Vector2.ZERO

	if event.is_action_pressed("ui_up"):
		new_dir = Vector2.UP
	elif event.is_action_pressed("ui_down"):
		new_dir = Vector2.DOWN
	elif event.is_action_pressed("ui_left"):
		new_dir = Vector2.LEFT
	elif event.is_action_pressed("ui_right"):
		new_dir = Vector2.RIGHT
	elif event.is_action_pressed("pause"):
		_toggle_pause()
		return

	if new_dir != Vector2.ZERO and _snake.has_method("set_direction"):
		_snake.set_direction(new_dir)


func _toggle_pause():
	if GameManager.current_state == GameManager.GameState.PLAYING:
		GameManager.change_state(GameManager.GameState.PAUSED)
		get_tree().paused = true
	elif GameManager.current_state == GameManager.GameState.PAUSED:
		GameManager.change_state(GameManager.GameState.PLAYING)
		get_tree().paused = false
