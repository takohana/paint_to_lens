extends Window

signal canvas_size_changed(new_size:Vector2i)
signal hand_enabled
signal hand_disabled
signal hand_image_file_changed(image_path:String)
signal hand_image_scale_changed(new_scale:float)
signal pen_position_changed(new_position:Vector2)
signal hand_image_horizontal_flip_changed(flip:bool)
signal brush_size_changed(brush_size:int)
signal brush_color_changed(brush_color:Color)
signal clear_canvas

@onready var conf = $AppConfig


func _ready():
	conf.initialize()


func _on_close_requested():
	hide()
