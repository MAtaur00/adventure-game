extends Control


@export var game_scene_path: String = "res://Scenes/MainScene.tscn"


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file(game_scene_path)


func _on_quit_button_pressed() -> void:
	get_tree().quit()
