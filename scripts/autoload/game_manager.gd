extends Node

enum GameState { MENU, PLAYING, PAUSED, GAME_OVER }

signal state_changed(new_state)
signal score_updated(new_score)
signal high_score_updated(new_high_score)

var current_state = GameState.MENU
var current_score = 0
var high_score = 0

const GRID_SIZE = 20
const INITIAL_SPEED = 0.15
const SPEED_INCREMENT = 0.005
const MIN_SPEED = 0.05

var grid_width = 0
var grid_height = 0


func _ready():
	high_score = SaveManager.load_high_score()
	_calculate_grid_dimensions()
	get_tree().get_root().size_changed.connect(_on_size_changed)


func _on_size_changed():
	_calculate_grid_dimensions()


func _calculate_grid_dimensions():
	var viewport_size = get_viewport().get_visible_rect().size
	grid_width = int(viewport_size.x) / GRID_SIZE
	grid_height = int(viewport_size.y) / GRID_SIZE


func change_state(new_state):
	if current_state == new_state:
		return
	current_state = new_state
	state_changed.emit(new_state)


func add_score(points = 10):
	var new_score = current_score + points
	current_score = new_score
	score_updated.emit(new_score)

	if new_score > high_score:
		high_score = new_score
		SaveManager.save_high_score(new_score)
		high_score_updated.emit(new_score)


func reset_game():
	current_score = 0
	score_updated.emit(0)
	change_state(GameState.PLAYING)


func grid_to_world(grid_pos):
	return grid_pos * GRID_SIZE + Vector2.ONE * (GRID_SIZE / 2.0)
