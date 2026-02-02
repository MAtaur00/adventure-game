extends CanvasLayer

@onready var inventory_screen: Control = $InventoryScreen
@onready var system_screen: Control = $SystemScreen

@export var main_menu_scene_path: String = "res://Scenes/UI/main_menu.tscn"

var screens: Array[Control]
var screen_titles := ["Inventory", "System"]
var current_screen_index := 0
var is_paused := false
var baseline_position: Vector2

var is_tweening := false

func _ready():
	baseline_position = inventory_screen.position
	screens = [inventory_screen, system_screen]
	_update_screen()
	visible = false

func toggle_pause():
	is_paused = !is_paused
	get_tree().paused = is_paused
	visible = is_paused
	
	if is_paused:
		for screen in screens:
			screen.position = baseline_position
		_update_screen()
	else:
		current_screen_index = 0
		for screen in screens:
			screen.position = baseline_position
		_update_screen()

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		toggle_pause()
		return
	
	if not is_paused:
		return
	
	if not is_tweening:
		if event.is_action_pressed("menu_right"):
			_next_screen()

		elif event.is_action_pressed("menu_left"):
			_prev_screen()


func _next_screen():
	var from_screen = screens[current_screen_index]
	
	current_screen_index += 1
	if current_screen_index >= screens.size():
		current_screen_index = 0
	
	var to_screen = screens[current_screen_index]
	
	var tween_offset = Vector2(screens[0].size.x, 0)
	_slide_screens(from_screen, to_screen, tween_offset)

func _prev_screen():
	var from_screen = screens[current_screen_index]
	
	current_screen_index -= 1
	if current_screen_index < 0:
		current_screen_index = screens.size() - 1
	
	var to_screen = screens[current_screen_index]

	var tween_offset = Vector2(-screens[0].size.x, 0)
	_slide_screens(from_screen, to_screen, tween_offset)

func _update_screen():
	for i in range(screens.size()):
		screens[i].visible = i == current_screen_index 
	

func _slide_screens(from_screen: Control, to_screen: Control, tween_offset: Vector2):
	is_tweening = true
	to_screen.visible = true
	to_screen.position = from_screen.position + tween_offset
	
	var tween = create_tween()
	tween.tween_property(from_screen, "position", from_screen.position - tween_offset, 0.3)
	tween.tween_property(to_screen, "position", from_screen.position, 0.3)
	
	tween.finished.connect(func():
		from_screen.visible = false
		is_tweening = false
	)

func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	visible = false
	get_tree().change_scene_to_file(main_menu_scene_path)

func _on_quit_button_pressed() -> void:
	get_tree().quit()
