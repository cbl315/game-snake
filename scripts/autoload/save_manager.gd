extends Node

const SAVE_PATH = "user://save.cfg"


func save_high_score(score):
	var config = ConfigFile.new()
	config.set_value("game", "high_score", score)
	var err = config.save(SAVE_PATH)
	return err == OK


func load_high_score():
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)

	if err != OK:
		return 0

	return config.get_value("game", "high_score", 0)
