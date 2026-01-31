class_name ReturnToSpawnState extends EnemyState


@export var return_speed := 40.0
@export var arrive_distance := 2.0

@export var wander_state: EnemyState

func enter() -> void:	
	pass

func exit() -> void:
	enemy.move_velocity = Vector2.ZERO

func physics_update(_delta: float) -> void:
	var dir := enemy.spawn_position - enemy.global_position
	var distance := dir.length()

	if distance <= arrive_distance:
		enemy.move_velocity = Vector2.ZERO
		state_machine.change_state(wander_state)
		return

	enemy.move_velocity = dir.normalized() * return_speed
