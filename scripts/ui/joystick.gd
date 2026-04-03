extends Control

signal direction_changed(direction)

var _is_pressed = false
var _knob_pos = Vector2.ZERO
var _outer_radius = 80.0
var _inner_radius = 35.0
var _touch_index = -1
var _center = Vector2.ZERO


func _ready():
	custom_minimum_size = Vector2(_outer_radius * 2 + 40, _outer_radius * 2 + 40)
	_center = Vector2(_outer_radius + 20, _outer_radius + 20)
	_knob_pos = _center


func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			if _is_in_area(event.position):
				_is_pressed = true
				_touch_index = event.index
				_update_knob(event.position)
		elif event.index == _touch_index:
			_is_pressed = false
			_touch_index = -1
			_knob_pos = _center
			direction_changed.emit(Vector2.ZERO)
			queue_redraw()
	elif event is InputEventScreenDrag and event.index == _touch_index and _is_pressed:
		_update_knob(event.position)


func _is_in_area(touch_pos):
	var local = touch_pos - global_position
	return local.distance_to(_center) <= _outer_radius * 1.5


func _update_knob(touch_pos):
	var local = touch_pos - global_position
	var diff = local - _center

	if diff.length() > _outer_radius:
		diff = diff.normalized() * _outer_radius

	_knob_pos = _center + diff
	var dir = diff.normalized()

	if diff.length() > 5.0:
		direction_changed.emit(dir)
	else:
		direction_changed.emit(Vector2.ZERO)
	queue_redraw()


func get_direction():
	if not _is_pressed:
		return Vector2.ZERO
	return (_knob_pos - _center).normalized()


func _draw():
	draw_circle(_center, _outer_radius, Color(1.0, 1.0, 1.0, 0.12))
	draw_arc(_center, _outer_radius, 0, TAU, 32, Color(1.0, 1.0, 1.0, 0.25), 2.0)
	var knob_color = Color(1.0, 1.0, 1.0, 0.7) if _is_pressed else Color(1.0, 1.0, 1.0, 0.4)
	draw_circle(_knob_pos, _inner_radius, knob_color)
