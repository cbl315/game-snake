extends Node

@onready var _title_label = $UI/MarginContainer/VBoxContainer/TitleLabel
@onready var _play_button = $UI/MarginContainer/VBoxContainer/PlayButton
@onready var _high_score_label = $UI/MarginContainer/VBoxContainer/HighScoreLabel


func _ready():
	GameManager.change_state(GameManager.GameState.MENU)
	_setup_ui()
	_connect_signals()


func _setup_ui():
	_title_label.add_theme_font_size_override("font_size", 64)
	_title_label.add_theme_color_override("font_color", Color(0.3, 0.8, 0.3))
	_play_button.add_theme_font_size_override("font_size", 28)
	_high_score_label.text = "Best: " + str(GameManager.high_score)
	_high_score_label.add_theme_font_size_override("font_size", 24)
	_high_score_label.add_theme_color_override("font_color", Color.YELLOW)


func _connect_signals():
	_play_button.pressed.connect(_on_play_pressed)
	GameManager.high_score_updated.connect(_on_high_score_updated)


func _on_play_pressed():
	get_tree().change_scene_to_file("res://scenes/game/game.tscn")


func _on_high_score_updated(new_high_score):
	_high_score_label.text = "Best: " + str(new_high_score)


func _input(event):
	if event.is_action_pressed("ui_accept"):
		_on_play_pressed()
