class_name WanderState extends EnemyState

@export var wander_radius := 40.0
@export var wander_speed := 20.0

var wander_direction := Vector2.ZERO
var is_wandering := false
var active := false

func enter() -> void:
	active = true
	start_wander_cycle()

func exit() -> void:
	active = false
	is_wandering = false
	enemy.move_velocity = Vector2.ZERO

func physics_update(_delta: float) -> void:	
	if not is_wandering:
		enemy.move_velocity = Vector2.ZERO
		return

	if enemy.global_position.distance_to(enemy.spawn_position) > wander_radius:
		wander_direction = (enemy.spawn_position - enemy.global_position).normalized()

	enemy.move_velocity = wander_direction * wander_speed

func start_wander_cycle() -> void:

	var tree := get_tree()
	if tree == null:
		return

	while active:
		if not is_instance_valid(owner):
			return

		# MOVE
		is_wandering = true
		wander_direction = Vector2(
			randf_range(-1, 1),
			randf_range(-1, 1)
		).normalized()

		await tree.create_timer(randf_range(1.0, 2.5)).timeout

		if not active:
			break

		# IDLE
		is_wandering = false
		await tree.create_timer(randf_range(0.5, 1.5)).timeout
