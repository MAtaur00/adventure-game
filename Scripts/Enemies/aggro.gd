class_name AggroState extends EnemyState

@export var aggro_speed := 50.0

var player : Node2D = null

func enter() -> void:
	player = find_player()

func physics_update(_delta: float) -> void:
	if not player:
		state_machine.change_state(
			state_machine.get_node("Wander")
		)
		return

	var direction = (player.global_position - enemy.global_position).normalized()
	enemy.move_velocity = direction * aggro_speed

func find_player() -> Node2D:
	var players = get_tree().get_nodes_in_group("player")
	return players[0] if players.size() > 0 else null
