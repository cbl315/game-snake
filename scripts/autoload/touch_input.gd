extends Node

signal swipe_detected(direction)

const MIN_SWIPE_DISTANCE = 50.0
const MAX_SWIPE_TIME = 0.5

var _touch_start_pos = Vector2.ZERO
var _touch_start_time = 0.0
var _is_touching = false


func _input(event):
	if event is InputEventScreenTouch and event.pressed:
		_touch_start_pos = event.position
		_touch_start_time = Time.get_ticks_msec() / 1000.0
		_is_touching = true
	elif event is InputEventScreenTouch and not event.pressed and _is_touching:
		_is_touching = false
		_process_swipe(event.position)


func _process_swipe(end_pos):
	var swipe_duration = (Time.get_ticks_msec() / 1000.0) - _touch_start_time

	if swipe_duration > MAX_SWIPE_TIME:
		return

	var swipe_vector = end_pos - _touch_start_pos
	var swipe_distance = swipe_vector.length()

	if swipe_distance < MIN_SWIPE_DISTANCE:
		return

	var direction = swipe_vector.normalized()
	var rounded_dir = _round_to_cardinal(direction)

	if rounded_dir != Vector2.ZERO:
		swipe_detected.emit(rounded_dir)


func _round_to_cardinal(direction):
	var abs_x = absf(direction.x)
	var abs_y = absf(direction.y)

	if abs_x > abs_y:
		return Vector2(signf(direction.x), 0.0)
	elif abs_y > abs_x:
		return Vector2(0.0, signf(direction.y))

	return Vector2.ZERO
