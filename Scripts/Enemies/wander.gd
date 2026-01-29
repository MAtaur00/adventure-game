class_name WanderState extends EnemyState

@export var wander_radius := 40.0
@export var wander_speed := 20.0

var wander_direction := Vector2.ZERO
var is_wandering := false
var active := false
var returning_to_spawn := false

func enter() -> void:
	active = true
	returning_to_spawn = false
	start_wander_cycle()

func exit() -> void:
	active = false
	is_wandering = false
	enemy.velocity = Vector2.ZERO

func physics_update(_delta: float) -> void:
	if returning_to_spawn:
		# Walk directly toward spawn
		var dir = (enemy.spawn_position - enemy.global_position).normalized()
		enemy.velocity = dir * wander_speed
		return	
	
	if not is_wandering:
		enemy.velocity = Vector2.ZERO
		return

	if enemy.global_position.distance_to(enemy.spawn_position) > wander_radius:
		wander_direction = (enemy.spawn_position - enemy.global_position).normalized()

	enemy.move_velocity = wander_direction * wander_speed

func start_wander_cycle() -> void:
	while active:
		if not is_instance_valid(owner):
			return
		# MOVE
		is_wandering = true
		wander_direction = Vector2(randf_range(-1,1), randf_range(-1,1)).normalized()
		await get_tree().create_timer(randf_range(1.0,2.5)).timeout

		if not is_instance_valid(owner):
			return
		# IDLE
		is_wandering = false
		await get_tree().create_timer(randf_range(0.5,1.5)).timeout
	
