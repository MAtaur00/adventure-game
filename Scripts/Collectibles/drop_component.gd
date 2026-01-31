class_name DropComponent extends Node

@export var coin_scene: PackedScene
@export_range(0.0, 1.0) var drop_chance := 1.0
@export var min_coins := 1
@export var max_coins := 1

func drop():
	if coin_scene == null:
		return
	
	if randf() > drop_chance:
		return
	
	if not owner or not owner is Node2D:
		return

	var drop_position: Vector2 = owner.global_position
	var amount := randi_range(min_coins, max_coins)

	for i in amount:
		call_deferred("_spawn_coin", drop_position)

func _spawn_coin(pos: Vector2) -> void:
	var coin = coin_scene.instantiate()
	coin.global_position = pos
	owner.get_parent().add_child(coin)
