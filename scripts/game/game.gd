extends Node2D

const SNAKE_COLORS = [
	Color(0.3, 0.5, 1.0), Color(1.0, 0.3, 0.3), Color(1.0, 0.7, 0.2),
	Color(0.8, 0.3, 0.8), Color(0.2, 0.8, 0.8), Color(1.0, 0.5, 0.5),
	Color(0.6, 0.4, 0.2), Color(0.9, 0.9, 0.3), Color(0.5, 0.8, 0.5),
	Color(0.7, 0.5, 1.0),
]

var _player = null
var _ai_controllers = []  # Array of {"controller": node, "snake": snake_node}
var _foods = []
var _respawn_timers = []
var _boost_button_pressed = false
var _hud = null
var _camera = null
var _joystick = null
var _minimap = null


func _ready():
	_build_world()
	_build_camera()
	_build_hud()
	_build_joystick()
	_build_boost_button()
	_build_minimap()
	_create_player()
	_spawn_initial_foods()
	_spawn_all_ai()
	GameManager.reset_game()


# ============ WORLD ============

func _build_world():
	var bg = ColorRect.new()
	bg.position = Vector2.ZERO
	bg.size = Vector2(GameManager.MAP_WIDTH, GameManager.MAP_HEIGHT)
	bg.color = Color(0.06, 0.10, 0.06)
	bg.z_index = -100
	add_child(bg)

	# Grid
	for x in range(0, int(GameManager.MAP_WIDTH) + 1, 50):
		var line = Line2D.new()
		line.width = 0.5
		line.default_color = Color(0.15, 0.2, 0.15, 0.5)
		line.add_point(Vector2(x, 0))
		line.add_point(Vector2(x, GameManager.MAP_HEIGHT))
		line.z_index = -99
		add_child(line)

	for y in range(0, int(GameManager.MAP_HEIGHT) + 1, 50):
		var line = Line2D.new()
		line.width = 0.5
		line.default_color = Color(0.15, 0.2, 0.15, 0.5)
		line.add_point(Vector2(0, y))
		line.add_point(Vector2(GameManager.MAP_WIDTH, y))
		line.z_index = -99
		add_child(line)

	# Border
	var border = Line2D.new()
	border.width = 4.0
	border.default_color = Color(1.0, 0.2, 0.2, 0.8)
	border.add_point(Vector2.ZERO)
	border.add_point(Vector2(GameManager.MAP_WIDTH, 0))
	border.add_point(Vector2(GameManager.MAP_WIDTH, GameManager.MAP_HEIGHT))
	border.add_point(Vector2(0, GameManager.MAP_HEIGHT))
	border.add_point(Vector2.ZERO)
	border.z_index = -98
	add_child(border)


func _build_camera():
	_camera = Camera2D.new()
	_camera.zoom = Vector2(1.0, 1.0)
	_camera.position_smoothing_enabled = true
	_camera.position_smoothing_speed = 8.0
	add_child(_camera)


# ============ PLAYER ============

func _create_player():
	_player = _make_snake(
		Vector2(GameManager.MAP_WIDTH / 2.0, GameManager.MAP_HEIGHT / 2.0),
		Color(0.3, 0.85, 0.3),
		true
	)


func _make_snake(pos, color, is_player):
	var snake = Node2D.new()
	snake.set_script(load("res://scripts/game/snake.gd"))
	snake.name = "Snake_" + str(get_child_count())
	add_child(snake)
	snake.setup(pos, color, is_player)
	snake.died.connect(_on_snake_died)
	return snake


# ============ FOOD ============

func _spawn_initial_foods():
	for i in range(GameManager.MAX_FOOD_COUNT):
		_spawn_food()


func _spawn_food():
	var pos = GameManager.random_map_position(50.0)
	_spawn_food_at(pos)


func _spawn_food_at(pos):
	var food = Node2D.new()
	food.set_script(load("res://scripts/game/food.gd"))
	food.name = "Food"
	add_child(food)
	food.setup(pos)
	_foods.append(food)


# ============ AI ============

func _spawn_all_ai():
	for i in range(GameManager.AI_COUNT):
		_spawn_one_ai()


func _spawn_one_ai():
	var pos = GameManager.random_map_position(200.0)
	var color = SNAKE_COLORS[randi() % SNAKE_COLORS.size()]
	var snake = _make_snake(pos, color, false)

	# Give AI extra length
	var extra = randi() % 15 + 5
	snake.grow(extra)

	# Randomize initial direction
	var angle = randf() * TAU
	snake._current_angle = angle
	snake._target_angle = angle

	# Create controller
	var controller = Node.new()
	controller.name = "AIController"
	controller.set_script(load("res://scripts/game/ai_snake.gd"))
	controller.snake = snake
	controller.game = self
	add_child(controller)

	_ai_controllers.append({"controller": controller, "snake": snake})


# ============ HUD ============

func _build_hud():
	_hud = $HUD


func _build_joystick():
	_joystick = Control.new()
	_joystick.set_script(load("res://scripts/ui/joystick.gd"))
	_joystick.name = "Joystick"
	_joystick.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	_joystick.offset_left = 20
	_joystick.offset_bottom = -30
	_joystick.custom_minimum_size = Vector2(200, 200)
	_hud.add_child(_joystick)


func _build_boost_button():
	var btn = Button.new()
	btn.name = "BoostButton"
	btn.text = "BOOST"
	btn.add_theme_font_size_override("font_size", 18)
	btn.modulate.a = 0.7
	btn.custom_minimum_size = Vector2(90, 90)
	btn.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	btn.offset_right = -25
	btn.offset_bottom = -25

	btn.button_down.connect(func(): _boost_button_pressed = true)
	btn.button_up.connect(func(): _boost_button_pressed = false)
	_hud.add_child(btn)


func _build_minimap():
	_minimap = Control.new()
	_minimap.set_script(load("res://scripts/ui/minimap.gd"))
	_minimap.name = "Minimap"
	_minimap.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_minimap.offset_right = -10
	_minimap.offset_top = 10
	_minimap.custom_minimum_size = Vector2(120, 120)
	_hud.add_child(_minimap)


# ============ GAME LOOP ============

func _process(delta):
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return

	# Player input
	if _player and _player.is_alive():
		if _joystick:
			var dir = _joystick.get_direction()
			if dir != Vector2.ZERO:
				_player.set_direction(dir)
		_player.set_boost(_boost_button_pressed or Input.is_key_pressed(KEY_SHIFT))

	# Camera follow
	if _player and _player.is_alive():
		_camera.position = _player.get_head_position()
		var length = _player.get_length()
		var zoom = clampf(1.0 - (length - 10) * 0.003, 0.4, 1.0)
		_camera.zoom = lerp(_camera.zoom, Vector2(zoom, zoom), 2.0 * delta)

	# Food collisions
	_check_food_collisions()

	# Snake collisions
	_check_snake_collisions()

	# AI respawn
	_process_respawns(delta)

	# Minimap
	if _minimap and _minimap.has_method("update_data"):
		var all_snakes = [_player]
		for entry in _ai_controllers:
			if is_instance_valid(entry["snake"]):
				all_snakes.append(entry["snake"])
		_minimap.update_data(_player, all_snakes, _foods)

	# HUD update
	_update_hud()


func _check_food_collisions():
	var all_snakes = [_player]
	for entry in _ai_controllers:
		if is_instance_valid(entry["snake"]) and entry["snake"].is_alive():
			all_snakes.append(entry["snake"])

	var eaten = []

	for food in _foods:
		if not is_instance_valid(food):
			eaten.append(food)
			continue
		for snake in all_snakes:
			if not snake.is_alive():
				continue
			if food.check_collision(snake.get_head_position(), GameManager.SNAKE_SEGMENT_RADIUS):
				snake.grow(food.get_grow_amount())
				if snake == _player:
					GameManager.add_score(food.get_score())
				eaten.append(food)
				break

	for food in eaten:
		_foods.erase(food)
		if is_instance_valid(food):
			food.queue_free()

	while _foods.size() < GameManager.MAX_FOOD_COUNT:
		_spawn_food()


func _check_snake_collisions():
	var all_snakes = [_player]
	for entry in _ai_controllers:
		if is_instance_valid(entry["snake"]) and entry["snake"].is_alive():
			all_snakes.append(entry["snake"])

	for snake in all_snakes:
		if not snake.is_alive():
			continue
		var head = snake.get_head_position()

		for other in all_snakes:
			if not other.is_alive() or other == snake:
				continue
			var body = other.get_body_positions()
			for seg in body:
				if head.distance_to(seg) < GameManager.SNAKE_SEGMENT_RADIUS * 1.8:
					# Kill this snake
					if snake == _player:
						# Player died
						snake._die()
					else:
						# AI died, give credit to killer
						if other == _player:
							GameManager.kill_count += 1
							GameManager.add_score(50)
						snake._die()
					break
			if not snake.is_alive():
				break


func _on_snake_died(snake):
	# Drop food
	for seg in snake.segments:
		if randi() % 3 == 0:
			_spawn_food_at(seg)

	# Check if AI
	for i in range(_ai_controllers.size() - 1, -1, -1):
		var entry = _ai_controllers[i]
		if entry["snake"] == snake:
			if is_instance_valid(entry["controller"]):
				entry["controller"].queue_free()
			_ai_controllers.remove_at(i)
			_respawn_timers.append(GameManager.AI_RESPAWN_TIME)
			snake.queue_free()
			return

	# Player died
	if snake == _player:
		_show_game_over()


func _process_respawns(delta):
	var new_timers = []
	for t in _respawn_timers:
		var remaining = t - delta
		if remaining <= 0:
			_spawn_one_ai()
		else:
			new_timers.append(remaining)
	_respawn_timers = new_timers


func _update_hud():
	# Update top-left HUD labels (rebuild if needed)
	var top_bar = _hud.find_child("TopBar", true, false)
	if not top_bar:
		top_bar = HBoxContainer.new()
		top_bar.name = "TopBar"
		top_bar.set_anchors_preset(Control.PRESET_TOP_LEFT)
		top_bar.offset_left = 15
		top_bar.offset_top = 15

		var sl = Label.new()
		sl.name = "ScoreLabel"
		sl.add_theme_font_size_override("font_size", 22)
		sl.add_theme_color_override("font_color", Color.WHITE)
		top_bar.add_child(sl)

		var ll = Label.new()
		ll.name = "LengthLabel"
		ll.add_theme_font_size_override("font_size", 22)
		ll.add_theme_color_override("font_color", Color.GREEN)
		top_bar.add_child(ll)

		var kl = Label.new()
		kl.name = "KillLabel"
		kl.add_theme_font_size_override("font_size", 22)
		kl.add_theme_color_override("font_color", Color.YELLOW)
		top_bar.add_child(kl)

		_hud.add_child(top_bar)

	var sl2 = top_bar.find_child("ScoreLabel", true, false)
	var ll2 = top_bar.find_child("LengthLabel", true, false)
	var kl2 = top_bar.find_child("KillLabel", true, false)

	if sl2:
		sl2.text = "Score: " + str(GameManager.current_score) + "  "
	if ll2 and _player:
		ll2.text = "Len: " + str(_player.get_length()) + "  "
	if kl2:
		kl2.text = "Kill: " + str(GameManager.kill_count)

	# Leaderboard
	var lb = _hud.find_child("LeaderboardPanel", true, false)
	if not lb:
		lb = VBoxContainer.new()
		lb.name = "LeaderboardPanel"
		lb.set_anchors_preset(Control.PRESET_TOP_RIGHT)
		lb.offset_right = -140
		lb.offset_top = 140
		_hud.add_child(lb)

	# Clear old entries
	for child in lb.get_children():
		child.queue_free()

	# Build rankings
	var rankings = []
	if _player and _player.is_alive():
		rankings.append({"name": "You", "length": _player.get_length()})
	for entry in _ai_controllers:
		if is_instance_valid(entry["snake"]) and entry["snake"].is_alive():
			rankings.append({"name": "Bot", "length": entry["snake"].get_length()})

	rankings.sort_custom(func(a, b): return a["length"] > b["length"])

	for i in range(mini(5, rankings.size())):
		var label = Label.new()
		var r = rankings[i]
		label.text = str(i + 1) + ". " + r["name"] + " (" + str(r["length"]) + ")"
		label.add_theme_font_size_override("font_size", 16)
		if r["name"] == "You":
			label.add_theme_color_override("font_color", Color.GREEN)
		else:
			label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
		lb.add_child(label)


# ============ GAME OVER ============

func _show_game_over():
	var panel = ColorRect.new()
	panel.name = "GameOverPanel"
	panel.color = Color(0.0, 0.0, 0.0, 0.75)
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP

	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.set_anchors_preset(Control.PRESET_CENTER)

	var go_label = Label.new()
	go_label.text = "GAME OVER"
	go_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	go_label.add_theme_font_size_override("font_size", 48)
	go_label.add_theme_color_override("font_color", Color.RED)
	vbox.add_child(go_label)

	var spacer1 = Control.new()
	spacer1.custom_minimum_size.y = 20
	vbox.add_child(spacer1)

	var info = Label.new()
	info.text = "Score: " + str(GameManager.current_score) + "  Kills: " + str(GameManager.kill_count)
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info.add_theme_font_size_override("font_size", 28)
	info.add_theme_color_override("font_color", Color.WHITE)
	vbox.add_child(info)

	var spacer2 = Control.new()
	spacer2.custom_minimum_size.y = 30
	vbox.add_child(spacer2)

	var btn = Button.new()
	btn.text = "Play Again"
	btn.add_theme_font_size_override("font_size", 24)
	btn.custom_minimum_size = Vector2(200, 60)
	btn.pressed.connect(_on_restart)
	vbox.add_child(btn)

	panel.add_child(vbox)
	_hud.add_child(panel)


func _on_restart():
	var panel = _hud.find_child("GameOverPanel", true, false)
	if panel:
		panel.queue_free()

	# Clear AI
	for entry in _ai_controllers:
		if is_instance_valid(entry["controller"]):
			entry["controller"].queue_free()
		if is_instance_valid(entry["snake"]):
			entry["snake"].queue_free()
	_ai_controllers.clear()
	_respawn_timers.clear()

	# Clear food
	for food in _foods:
		if is_instance_valid(food):
			food.queue_free()
	_foods.clear()

	# Reset player
	if _player:
		_player.reset(Vector2(GameManager.MAP_WIDTH / 2.0, GameManager.MAP_HEIGHT / 2.0))
	else:
		_create_player()

	_spawn_initial_foods()
	_spawn_all_ai()
	GameManager.reset_game()


# ============ INPUT ============

func _input(event):
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return

	if not _player or not _player.is_alive():
		return

	# Keyboard fallback
	var new_dir = Vector2.ZERO
	if event.is_action_pressed("ui_up"):
		new_dir = Vector2.UP
	elif event.is_action_pressed("ui_down"):
		new_dir = Vector2.DOWN
	elif event.is_action_pressed("ui_left"):
		new_dir = Vector2.LEFT
	elif event.is_action_pressed("ui_right"):
		new_dir = Vector2.RIGHT

	if new_dir != Vector2.ZERO:
		_player.set_direction(new_dir)
