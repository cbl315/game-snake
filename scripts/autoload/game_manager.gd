extends Node

enum GameState { MENU, PLAYING, PAUSED, GAME_OVER }

signal state_changed(new_state)
signal score_updated(new_score)
signal high_score_updated(new_high_score)
signal length_updated(new_length)

var current_state = GameState.MENU
var current_score = 0
var high_score = 0
var current_length = 0
var kill_count = 0

# Map
const MAP_WIDTH = 2000.0
const MAP_HEIGHT = 2000.0

# Snake
const SNAKE_SEGMENT_RADIUS = 8.0
const SNAKE_SEGMENT_GAP = 6.0
const INITIAL_LENGTH = 10
const INITIAL_SPEED = 150.0
const BOOST_SPEED = 300.0

# Food
const MAX_FOOD_COUNT = 50
const FOOD_RADIUS = 5.0

# AI
const AI_COUNT = 15
const AI_RESPAWN_TIME = 3.0


func _ready():
	high_score = SaveManager.load_high_score()


func change_state(new_state):
	if current_state == new_state:
		return
	current_state = new_state
	state_changed.emit(new_state)


func add_score(points):
	current_score += points
	score_updated.emit(current_score)
	if current_score > high_score:
		high_score = current_score
		SaveManager.save_high_score(high_score)
		high_score_updated.emit(high_score)


func set_length(length):
	current_length = length
	length_updated.emit(length)


func reset_game():
	current_score = 0
	kill_count = 0
	current_length = INITIAL_LENGTH
	score_updated.emit(0)
	length_updated.emit(INITIAL_LENGTH)
	change_state(GameState.PLAYING)


func random_map_position(margin = 100.0):
	return Vector2(
		randf_range(margin, MAP_WIDTH - margin),
		randf_range(margin, MAP_HEIGHT - margin)
	)


func clamp_to_map(pos):
	return Vector2(
		clampf(pos.x, SNAKE_SEGMENT_RADIUS, MAP_WIDTH - SNAKE_SEGMENT_RADIUS),
		clampf(pos.y, SNAKE_SEGMENT_RADIUS, MAP_HEIGHT - SNAKE_SEGMENT_RADIUS)
	)
