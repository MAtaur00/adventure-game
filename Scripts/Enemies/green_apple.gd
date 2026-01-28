extends CharacterBody2D


@export var health : float = 3.0
@export var knockback_strength : float = 90.0
@export var knockback_decay : float = 300.0
@export var hitstop_duration : float = 0.1

var knockback_velocity := Vector2.ZERO

var frozen : bool = false

func _ready() -> void:
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
		find_player()

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
