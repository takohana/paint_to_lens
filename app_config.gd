extends VBoxContainer

const INIT_PRESET_FILE_PATH = "user://_lastpreset"
const PRESET_DIRECTORY_PATH = "user://preset"
const USERIMAGEFILE_DIERCTORY_PATH = "user://img"
const PRESET_FILE_EXT = ".ini"
const SECT = "CONFIG"
const ISPRESETDEFAULT = "is_last_preset_default"
const LASTPRESETNAME = "last_preset_name"
const PRESETFILEVERSION = "1"
const KEY_PRESETFILEVERSION = "config_version"
const CANVASWIDTH = "canvas_width"
const CANVASHEIGHT = "canvas_height"
const SHOWHAND = "show_hand"
const HANDIMAGEPATH = "hand_image_file_path"
const HANDIMAGESCALE = "hand_image_scale"
const PENPOSITIONX = "pen_position_x"
const PENPOSITIONY = "pen_position_y"
const HANDHFLIP = "hand_image_horizontal_flip"
const BRUSHSIZE = "brush_size"
const BRUSHCOLOR = "brush_color"


@onready var root = $"../../ConfigWindow"
@onready var def = $"../DefaultConfig"

@onready var lineedit_preset_name = $"PresetFileSetting/MarginContainer/VBoxContainer/LineEditPresetName"
@onready var dialog_load_preset = $"../LoadPresetDialog"
@onready var dialog_save_preset = $"../SavePresetDialog"
@onready var spinbox_canvas_width = $"CanvasSizeSetting/MarginContainer/HBoxContainer/SpinBoxCanvasW"
@onready var spinbox_canvas_height = $"CanvasSizeSetting/MarginContainer/HBoxContainer/SpinBoxCanvasH"
@onready var checkbutton_show_hand_and_pen = $"ToggleHandSetting/HBoxContainer/CheckButtonToggleHand"
@onready var lineedit_hand_image_file_path = $"HandFileSetting/MarginContainer/VBoxContainer/LineEditHandFileName"
@onready var dialog_load_hand_image = $"../LoadHandImageDialog"
@onready var label_hand_image_scale = $"HandImageScaleSetting/LabelHandImageScale"
@onready var hscrollbar_hand_image_scale = $"HandImageScaleSetting/MarginContainer/HScrollBarHandImageScale"
@onready var spinbox_pen_position_x_on_hand_image = $"PenPositionSetting/MarginContainer/HBoxContainer/SpinBoxPenPositionX"
@onready var spinbox_pen_position_y_on_hand_image = $"PenPositionSetting/MarginContainer/HBoxContainer/SpinBoxPenPositionY"
@onready var checkbutton_hand_flip_h = $"ToggleHandHorizontalFlip/HBoxContainer/CheckButtonToggleHandHorizontalFlip"
@onready var label_brush_size = $"BrushSizeSetting/LabelBrushSize"
@onready var hscrollbar_brush_size = $"BrushSizeSetting/MarginContainer/HScrollBarBrushSize"
@onready var colorpicker_brush_color = $"BrushColorSetting/HBoxContainer/ColorPickerBrush"
@onready var label_brush_alpha = $"BrushColorSetting/LabelBrushAlpha"
@onready var dialog_reset_confirm = $"../ResetConfigConfirmationDialog"


func _ready():
	create_requied_directory_if_not_exists()
	set_root_subfolder()


func create_requied_directory_if_not_exists():
	var dirs = [PRESET_DIRECTORY_PATH, USERIMAGEFILE_DIERCTORY_PATH]
	for d in dirs:
		if not DirAccess.dir_exists_absolute(d):
			DirAccess.make_dir_absolute(d)


func set_root_subfolder():
	for d in [dialog_load_preset, dialog_save_preset]:
		d.set_root_subfolder(PRESET_DIRECTORY_PATH)
	dialog_load_hand_image.set_root_subfolder(USERIMAGEFILE_DIERCTORY_PATH)

func save_current_preset_name_to_file():
	var preset_name = lineedit_preset_name.text
	var preset_filepath = PRESET_DIRECTORY_PATH + "/" + preset_name + PRESET_FILE_EXT
	var init_config = ConfigFile.new()

	if preset_name.length() > 0 and FileAccess.file_exists(preset_filepath):
		init_config.set_value(SECT, ISPRESETDEFAULT, false)
	else:
		init_config.set_value(SECT, ISPRESETDEFAULT, true)
	init_config.set_value(SECT, LASTPRESETNAME, preset_name)
	init_config.save(INIT_PRESET_FILE_PATH)
		

func initialize():
	if FileAccess.file_exists(INIT_PRESET_FILE_PATH):
		var init_config = ConfigFile.new()
		var ret = init_config.load(INIT_PRESET_FILE_PATH)
		if ret != OK:
			set_default_config()
		else:
			var is_default_preset = init_config.get_value(SECT, ISPRESETDEFAULT, false)
			if is_default_preset:
				set_default_config()
			else:
				lineedit_preset_name.text = init_config.get_value(SECT, LASTPRESETNAME)
				load_preset_file()
	else:
		set_default_config()


func set_default_config():
	lineedit_preset_name.text = ""
	spinbox_canvas_width.value = def.canvas_size.x
	spinbox_canvas_height.value = def.canvas_size.y
	checkbutton_show_hand_and_pen.button_pressed = def.show_hand_and_pen
	lineedit_hand_image_file_path.text = def.hand_image_file_path
	apply_hand_image()
	hscrollbar_hand_image_scale.value = def.hand_image_scale
	spinbox_pen_position_x_on_hand_image.value = def.pen_position_on_hand_image.x
	spinbox_pen_position_y_on_hand_image.value = def.pen_position_on_hand_image.y
	checkbutton_hand_flip_h.button_pressed = def.hand_image_horizontal_flip
	hscrollbar_brush_size.value = def.brush_size
	colorpicker_brush_color.color = def.brush_color
	colorpicker_brush_color.color.a = def.brush_alpha
	apply_brush_color()
	save_current_preset_name_to_file()


func load_preset_file():
	var preset_filepath = preset_name_to_path(lineedit_preset_name.text)
	if not FileAccess.file_exists(preset_filepath):
		printerr("Preset file '%S' is not exists." % preset_filepath)
		set_default_config()
	else:
		var preset = ConfigFile.new()
		var ret = preset.load(preset_filepath)
		if ret != OK:
			printerr("Preset file '%S' loading failed." % preset_filepath)
			set_default_config()
			return
		if preset.get_value(SECT, KEY_PRESETFILEVERSION, 0) != PRESETFILEVERSION:
			printerr("Preset file '%S' have different version" % preset_filepath)
			set_default_config()
			return
		spinbox_canvas_width.value = preset.get_value(SECT, CANVASWIDTH)
		spinbox_canvas_height.value = preset.get_value(SECT, CANVASHEIGHT)
		checkbutton_show_hand_and_pen.button_pressed = preset.get_value(SECT, SHOWHAND)
		lineedit_hand_image_file_path.text = preset.get_value(SECT, HANDIMAGEPATH)
		apply_hand_image()
		hscrollbar_hand_image_scale.value = preset.get_value(SECT, HANDIMAGESCALE)
		spinbox_pen_position_x_on_hand_image.value = preset.get_value(SECT, PENPOSITIONX)
		spinbox_pen_position_y_on_hand_image.value = preset.get_value(SECT, PENPOSITIONY)
		checkbutton_hand_flip_h.button_pressed = preset.get_value(SECT, HANDHFLIP)
		hscrollbar_brush_size.value = preset.get_value(SECT, BRUSHSIZE)
		colorpicker_brush_color.color = preset.get_value(SECT, BRUSHCOLOR)
		apply_brush_color()
		save_current_preset_name_to_file()


func save_preset_file():
	var filepath = PRESET_DIRECTORY_PATH + "/" + lineedit_preset_name.text + PRESET_FILE_EXT
	var preset = ConfigFile.new()
	preset.set_value(SECT, KEY_PRESETFILEVERSION, PRESETFILEVERSION)
	preset.set_value(SECT, CANVASWIDTH, spinbox_canvas_width.value)
	preset.set_value(SECT, CANVASHEIGHT, spinbox_canvas_height.value)
	preset.set_value(SECT, SHOWHAND, checkbutton_show_hand_and_pen.button_pressed)
	preset.set_value(SECT, HANDIMAGEPATH, lineedit_hand_image_file_path.text)
	preset.set_value(SECT, HANDIMAGESCALE, hscrollbar_hand_image_scale.value)
	preset.set_value(SECT, PENPOSITIONX, spinbox_pen_position_x_on_hand_image.value)
	preset.set_value(SECT, PENPOSITIONY, spinbox_pen_position_y_on_hand_image.value)
	preset.set_value(SECT, HANDHFLIP, checkbutton_hand_flip_h.button_pressed)
	preset.set_value(SECT, BRUSHSIZE, hscrollbar_brush_size.value)
	preset.set_value(SECT, BRUSHCOLOR, colorpicker_brush_color.color)
	preset.save(filepath)
	save_current_preset_name_to_file()
	


func apply_hand_image():
	var hand_image_filepath = lineedit_hand_image_file_path.text
	if hand_image_filepath.begins_with("res://"):
		root.hand_image_file_changed.emit(hand_image_filepath)
	elif not FileAccess.file_exists(hand_image_filepath):
		printerr("Hand image file not found '%s'" % hand_image_filepath)
		lineedit_hand_image_file_path.text = def.hand_image_file_path
		root.hand_image_file_changed.emit(def.hand_image_file_path)
		return null
	else:
		root.hand_image_file_changed.emit(hand_image_filepath)


func apply_brush_color():
	label_brush_alpha.text = "Brush Alpha: " + str(snapped(colorpicker_brush_color.color.a, 0.1))
	root.brush_color_changed.emit(colorpicker_brush_color.color)


func trim_prefix_file_path_to_name(prefix_filepath):
	return prefix_filepath.trim_prefix(PRESET_DIRECTORY_PATH + "/").trim_suffix(PRESET_FILE_EXT)


func preset_name_to_path(preset_name):
	return PRESET_DIRECTORY_PATH + "/" + preset_name + PRESET_FILE_EXT


func _on_button_clear_pressed():
	root.clear_canvas.emit()


func _on_color_picker_brush_color_changed(_color):
	apply_brush_color()


func _on_h_scroll_bar_brush_size_value_changed(value):
	label_brush_size.text = "Brush Size: " + str(value) + "px"
	root.brush_size_changed.emit(value)


func _on_spin_box_canvas_w_value_changed(value):
	root.canvas_size_changed.emit(Vector2i(int(value), int(spinbox_canvas_height.value)))


func _on_spin_box_canvas_h_value_changed(value):
	root.canvas_size_changed.emit(Vector2i(int(spinbox_canvas_width.value), int(value)))


func _on_check_button_toggle_hand_toggled(button_pressed):
	if button_pressed:
		root.hand_enabled.emit()
	else:
		root.hand_disabled.emit()


func _on_h_scroll_bar_hand_image_scale_value_changed(value):
	label_hand_image_scale.text = "Hand Image Scale: " + str(value)
	root.hand_image_scale_changed.emit(value)


func _on_spin_box_pen_position_x_value_changed(value):
	var offset = Vector2(-value, -spinbox_pen_position_y_on_hand_image.value)
	root.pen_position_changed.emit(offset)


func _on_spin_box_pen_position_y_value_changed(value):
	var offset = Vector2(-spinbox_pen_position_x_on_hand_image.value, -value)
	root.pen_position_changed.emit(offset)


func _on_check_button_toggle_hand_horizontal_flip_toggled(button_pressed):
	root.hand_image_horizontal_flip_changed.emit(button_pressed)


func _on_button_save_preset_pressed():
	dialog_save_preset.popup_centered()


func _on_save_preset_dialog_file_selected(path):
	lineedit_preset_name.text = trim_prefix_file_path_to_name(path)
	save_preset_file()


func _on_button_load_preset_pressed():
	dialog_load_preset.popup_centered()


func _on_load_preset_dialog_file_selected(path):
	lineedit_preset_name.text = trim_prefix_file_path_to_name(path)
	load_preset_file()


func _on_button_load_hand_image_file_pressed():
	dialog_load_hand_image.popup_centered()


func _on_load_hand_image_dialog_file_selected(path):
	lineedit_hand_image_file_path.text = path
	apply_hand_image()


func _on_button_load_default_hand_image_pressed():
	lineedit_hand_image_file_path.text = def.hand_image_file_path
	apply_hand_image()


func _on_button_reset_config_pressed():
	dialog_reset_confirm.popup_centered()


func _on_reset_config_confirmation_dialog_confirmed():
	set_default_config()
