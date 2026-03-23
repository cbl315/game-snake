extends Node

var _sfx_players = []
var _music_player

var sfx_volume = 1.0
var music_volume = 0.5
var _sfx_library = {}


func _ready():
	for i in range(5):
		var player = AudioStreamPlayer.new()
		player.bus = "SFX"
		add_child(player)
		_sfx_players.append(player)

	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Music"
	add_child(_music_player)

	_load_sfx()


func _load_sfx():
	var sfx_paths = {
		"eat": "res://assets/audio/eat.wav",
		"game_over": "res://assets/audio/game_over.wav",
	}

	for key in sfx_paths:
		var path = sfx_paths[key]
		if ResourceLoader.exists(path):
			_sfx_library[key] = load(path)


func play_sfx(name):
	if not _sfx_library.has(name):
		return

	var stream = _sfx_library[name]

	for player in _sfx_players:
		if not player.playing:
			player.stream = stream
			player.volume_db = linear_to_db(sfx_volume)
			player.play()
			break
