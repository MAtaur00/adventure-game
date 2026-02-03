extends Node

const SAVE_PATH := "user://savegame.save"
@export var main_scene_path: String = "res://Scenes/MainScene.tscn"

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func save_game(data: Dictionary) -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_var(data)
	file.close()

func _on_save_button_pressed() -> void:
	var player = get_tree().current_scene.get_node("Player")
	var coinUI = get_tree().current_scene.get_node("CoinUI")
	
	var save_data := {
		"scene": get_tree().current_scene.scene_file_path,
		"player_position": player.global_position,
		"health": player.health.current_health,
		"coins": coinUI.coin_count
	}
	SaveManager.save_game(save_data)

func load_save_data() -> Dictionary:
	if not has_save():
		return {}
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var data = file.get_var()
	file.close()
	return data

func load_game():
	if not has_save():
		return
	
	var data = load_save_data()
	
	get_tree().paused = false
	get_tree().change_scene_to_file(data.scene)
	
	await get_tree().scene_changed
	
	var player = get_tree().current_scene.get_node("Player")
	var coinUI = get_tree().current_scene.get_node("CoinUI")
	var camera = player.get_node("Camera2D")
	var inventory_coins = get_tree().current_scene.get_node("GameController").get_node("InventoryComponent")
	inventory_coins.coins = data.coins
	player.global_position = data.player_position
	player.health.current_health = data.health
	coinUI.add_coins(data.coins)
	camera.snap_to_position(player.global_position)
