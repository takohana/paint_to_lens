extends Control


var brush_size = 32
var brush_color = Color.PINK #ffc0cb

const K_POINTS = "points"
const K_SIZE = "size"
const K_COLOR = "color"
var stroke_list = []
var current_stroke = {}

var last_mouse_pos = null
var mouse_left_button_down = false

var show_hand_and_pen = true


func _ready():
	set_process(true)


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.is_pressed():
			mouse_left_button_down = true
		if event.button_index == 1 and not event.is_pressed():
			mouse_left_button_down = false


func _unhandled_input(event):
	if event.is_action_pressed("clear_canvas"):
		clear_canvas()
	if event.is_action_pressed("toggle_config_window"):
		if $"ConfigWindow".visible:
			$"ConfigWindow".hide()
		else:
			$"ConfigWindow".show()


func _process(_delta):
	var mouse_pos = get_viewport().get_mouse_position()
	
	if mouse_left_button_down:
		if current_stroke.size() == 0:
			# Start New Stroke
			current_stroke = {K_SIZE: brush_size, K_COLOR: brush_color, K_POINTS: [mouse_pos]}
			stroke_list.append(current_stroke)
		elif mouse_pos.distance_to(last_mouse_pos) >= 1:
			# Continue Stroke
			current_stroke[K_POINTS].append(mouse_pos)
		else:
			pass
		last_mouse_pos = mouse_pos
		queue_redraw()
		return
	else:
		if current_stroke.size() >= 0:
			#End Stroke
			current_stroke = {}
		else:
			pass
		last_mouse_pos = null


func _draw():
	var stroke
	var idx = stroke_list.size() - 1
	while (idx >= 0):
		stroke = stroke_list[idx]
		var b_size = stroke[K_SIZE]
		var b_color = stroke[K_COLOR]
		var last_point = stroke[K_POINTS][0]
		draw_circle(last_point, b_size / 2, b_color)
		for point in stroke[K_POINTS].slice(1):
			draw_line(last_point, point, b_color, b_size, false)
			draw_circle(point, b_size / 2, b_color)
			last_point = point
		if stroke[K_POINTS].size() >= 2:
			draw_circle(stroke[K_POINTS][-1], b_size / 2, b_color)
		idx -= 1


func clear_canvas():
	stroke_list.clear()
	queue_redraw()


func _on_check_button_toggle_hand_toggled(button_pressed):
	show_hand_and_pen = button_pressed


func _on_config_window_brush_size_changed(_brush_size):
	brush_size = _brush_size


func _on_config_window_brush_color_changed(_brush_color):
	brush_color = _brush_color


func _on_config_window_clear_canvas():
	clear_canvas()


func _on_config_window_canvas_size_changed(new_size):
	get_window().set_size(new_size)
