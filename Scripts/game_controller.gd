class_name GameController extends Node


@onready var inventory: InventoryComponent = $InventoryComponent

#var main_menu_screen = preload("res://scenes/ui/main_menu_screen.tscn")
#var pause_menu_screen = preload("res://scenes/ui/pause_menu_screen.tscn")
#var level_1 = preload("res://scenes/levels/level1.tscn")

@onready var coin_ui: CoinUI = get_tree().get_first_node_in_group("CoinUI")

@onready var pause_menu = get_node("/root/Main/PauseMenu")

@onready var player: Player = get_node("/root/Main/Player")
var respawn_point: Vector2
@export var respawn_delay := 1.0

func _ready():
	inventory.coins_changed.connect(_on_coins_changed)
	respawn_point = player.global_position
	player.died.connect(_on_player_died)

func add_coins(amount: int) -> void:
	inventory.add_coins(amount)

func _on_coins_changed(amount: int):
	if coin_ui:
		coin_ui.set_coins(amount)

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		pause_menu.toggle_pause()

func _on_player_died():
	player.input_locked = true
	player.movement_locked = true
	player.actions_locked = true
	player.set_physics_process(false)
	await get_tree().create_timer(respawn_delay).timeout
	respawn_player()

func respawn_player():
	player.global_position = respawn_point
	player.health.reset()
	player.set_physics_process(true)
	player.input_locked = false
	player.movement_locked = false
	player.actions_locked = false


func set_respawn_point(pos: Vector2):
	respawn_point = pos
