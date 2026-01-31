class_name AggroState extends EnemyState

@export var aggro_speed := 50.0

@export var leash_distance := 120.0
@export var return_state: EnemyState

@export var wander_state : EnemyState

var player : Node2D = null

func enter() -> void:
	player = find_player()

func physics_update(_delta: float) -> void:
	
	var distance_from_spawn := enemy.global_position.distance_to(enemy.spawn_position)
	
	if distance_from_spawn > leash_distance:
		state_machine.change_state(return_state)
		return
	
	if not player:
		state_machine.change_state(wander_state)
		return

	var direction = (player.global_position - enemy.global_position).normalized()
	enemy.move_velocity = direction * aggro_speed

func find_player() -> Node2D:
	var players = get_tree().get_nodes_in_group("player")
	return players[0] if players.size() > 0 else null
