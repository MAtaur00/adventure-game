class_name GreenApple extends CharacterBody2D


@export var health : float = 3.0
@export var knockback_strength : float = 90.0
@export var knockback_decay : float = 300.0
@export var hitstop_duration : float = 0.1

var knockback_velocity := Vector2.ZERO

var spawn_position := Vector2.ZERO

enum enemyState { WANDER, AGGRO }
var state: enemyState = enemyState.WANDER

@export var wander_radius := 40.0
@export var wander_speed := 20.0
@export var aggro_speed := 50.0

var wander_direction := Vector2.ZERO
var is_wandering : bool = false

var player: Node2D = null

var frozen : bool = false

func _ready() -> void:
	spawn_position = global_position
	start_wander_cycle()
	add_to_group("enemy")

func take_damage(weapon_damage : float, hit_direction : Vector2):
	health -= weapon_damage
	
	flash_white(0.05)
	
	# Wait for hitstop to finish, then apply knockback
	await GlobalHitstop.hitstop(0.1)
	knockback_velocity = hit_direction * knockback_strength
	
	if health <= 0.0:
		die()

func die() -> void:
	queue_free()

func _physics_process(delta):
	
	if knockback_velocity.length() > 1:
		velocity = knockback_velocity
	else:
		match state:
			enemyState.WANDER:
				wander(delta)
			enemyState.AGGRO:
				aggro(delta)

	move_and_slide()

	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_decay * delta)


func find_player() -> void:
	velocity = Vector2.ZERO
	pass


func flash_white(duration: float = 0.05) -> void:
	var mat = $Sprite2D.material
	if mat == null:
		return # safety check

	# Set flash to full white
	mat.set_shader_parameter("flash_amount", 1.0)

	# Tween back to 0 (normal sprite)
	var tween = create_tween()
	tween.tween_property(mat, "shader_parameter/flash_amount", 0.0, duration)


func pick_new_wander_direction():
	wander_direction = Vector2(randf_range(-1, 1),randf_range(-1, 1)).normalized()
	pass

func wander(_delta):
	# If too far from spawn, walk back toward it
	if not is_wandering:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# leash back to spawn
	if global_position.distance_to(spawn_position) > wander_radius:
		wander_direction = (spawn_position - global_position).normalized()

	velocity = wander_direction * wander_speed
	move_and_slide()

func start_wander_cycle():
	while true:
		# MOVE phase
		is_wandering = true
		pick_new_wander_direction()
		await get_tree().create_timer(randf_range(1.0, 2.5)).timeout

		# IDLE phase
		is_wandering = false
		wander_direction = Vector2.ZERO
		await get_tree().create_timer(randf_range(0.5, 1.5)).timeout


func _on_aggro_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body
		state = enemyState.AGGRO
	pass # Replace with function body.


func _on_aggro_area_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
		state = enemyState.WANDER
	pass # Replace with function body.

func aggro(_delta):
	if not player:
		state = enemyState.WANDER
		return

	var direction = (player.global_position - global_position).normalized()
	velocity = direction * aggro_speed
	move_and_slide()
