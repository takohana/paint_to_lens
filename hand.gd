extends Sprite2D

var follow_mouse = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == 2 and event.is_pressed():
			follow_mouse = not follow_mouse

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if follow_mouse:
		position = get_viewport().get_mouse_position()


func _on_config_window_hand_enabled():
	set_visible(true)


func _on_config_window_hand_disabled():
	set_visible(false)


func _on_config_window_hand_image_scale_changed(image_scale):
	set_scale(Vector2(image_scale, image_scale))
	

func _on_config_window_pen_position_changed(new_position):
	if flip_h:
		new_position.x = -1 * (texture.get_width() + new_position.x)
	set_offset(new_position)


func _on_config_window_hand_image_horizontal_flip_changed(flip):
	# No change, Do nothing 
	if flip_h == flip:
		return
	# Recalculate offset.x
	offset.x = -1 * (texture.get_width() + offset.x)
	flip_h = flip


func _on_config_window_hand_image_file_changed(image_path:String):
	if image_path.begins_with("res://"):
		texture = load(image_path)
	else:
		var img = Image.new()
		img.load(image_path)
		texture = ImageTexture.create_from_image(img)

