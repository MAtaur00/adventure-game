extends Node

#var main_menu_screen = preload("res://scenes/ui/main_menu_screen.tscn")
#var pause_menu_screen = preload("res://scenes/ui/pause_menu_screen.tscn")
#var level_1 = preload("res://scenes/levels/level1.tscn")

var coins_collected: int = 0

func collect_coin(value: int):
	coins_collected += value
	#EventController.emit_signal("collect_coin", coins_collected)


func player_death(value: bool) -> void:
	var updateUI: bool = false
	if coins_collected != 0:
		updateUI = true
	
	#if value:
		#coins_collected = 0
		#
	#if updateUI:
		#EventController.emit_signal("coins_dropped", coins_collected)
		
	restart_level()


func start_game():
	if get_tree().paused:
		continue_game()
		return
	
	#transition_to_scene(level_1.resource_path)


func exit_game():
	get_tree().quit()


#func pause_game():
	#get_tree().paused = true
	#var pause_menu_screen_instance = pause_menu_screen.instantiate()
	#get_tree().get_root().add_child(pause_menu_screen_instance)
#
#
#func main_menu():
	#var main_menu_screen_instance = main_menu_screen.instantiate()
	#get_tree().get_root().add_child(main_menu_screen_instance)


func continue_game():
	get_tree().paused = false


func restart_level():
	coins_collected = 0
	get_tree().reload_current_scene()


func transition_to_scene(scene_path):
	await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_file(scene_path)

#func _process(delta):
	#if Input.is_action_just_pressed("esc") and !get_tree().paused:
		#pause_game()
