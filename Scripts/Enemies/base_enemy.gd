class_name Enemy extends CharacterBody2D

# --------------------
# STATS
# --------------------
@export var knockback_strength : float = 90.0
@export var knockback_decay : float = 300.0
@export var hitstop_duration : float = 0.1

@onready var damage_hitbox: Area2D = $DamageHitbox

@export var damage_dealt : int = 1

# --------------------
# MOVEMENT
# --------------------
@export var aggro_speed := 50.0

@onready var enemy_state_machine: Node = $EnemyStateMachine
@onready var health: HealthComponent = $HealthComponent
@onready var wander: WanderState = $EnemyStateMachine/Wander
@onready var aggro: AggroState = $EnemyStateMachine/Aggro
@onready var return_to_spawn: ReturnToSpawnState = $EnemyStateMachine/ReturnToSpawn
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D

@onready var drop_component: DropComponent = $DropComponent


# States write to this. base_enemy.gd is the only script that touches `velocity`
var move_velocity: Vector2 = Vector2.ZERO

var last_move_direction: Vector2 = Vector2.DOWN
var facing_direction: Vector2 = Vector2.RIGHT

var knockback_velocity := Vector2.ZERO
var spawn_position := Vector2.ZERO

# --------------------
# STATE
# --------------------

var wander_direction := Vector2.ZERO
var is_wandering := false
var frozen := false

# --------------------
# LIFECYCLE
# --------------------
func _ready() -> void:
	spawn_position = global_position
	
	var mat := sprite.material
	if mat != null:
		sprite.material = mat.duplicate(true)
	
	health.damaged.connect(_on_damaged)
	health.died.connect(_on_died)
	add_to_group("enemy")

func _physics_process(delta: float) -> void:
	if frozen:
		return
	
	move_velocity = Vector2.ZERO
	enemy_state_machine.physics_update(delta)

	# --- Combine movement + knockback for physics ---
	if knockback_velocity.length() > 1:
		velocity = knockback_velocity
	else: velocity = move_velocity + knockback_velocity
	move_and_slide()

	# --- Decay knockback ---
	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_decay * delta)
	
	update_animation(velocity)

# --------------------
# HIT FLASH
# --------------------
func flash_white(duration: float = 0.05) -> void:
	var mat = sprite.material
	if mat == null:
		return

	mat.set_shader_parameter("flash_amount", 1.0)
	var tween := create_tween()
	tween.tween_property(mat, "shader_parameter/flash_amount", 0.0, duration)

# --------------------
# AGGRO SIGNALS
# --------------------
func _on_aggro_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		enemy_state_machine.change_state(aggro)

func _on_aggro_area_area_exited(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		enemy_state_machine.change_state(return_to_spawn)

# --------------------
# COMBAT SIGNALS
# --------------------
func _on_damaged(_damage: float, hit_direction: Vector2 = Vector2.ZERO) -> void:
	flash_white(0.05)
	apply_knockback(hit_direction)
	await GlobalHitstop.hitstop(hitstop_duration)

func _on_died() -> void:
	if has_node("DropComponent"):
		drop_component.drop()
	queue_free()


func apply_knockback(direction: Vector2) -> void:
	knockback_velocity = direction.normalized() * knockback_strength
	

func get_direction_from_velocity(enemy_velocity: Vector2) -> String:
	if enemy_velocity.length() == 0:
		# No movement → use last movement direction
		if last_move_direction.y < 0:
			return "up"
		elif last_move_direction.y > 0:
			return "down"
		else:
			return "side"

	# Determine based on angle
	var angle_deg = rad_to_deg(velocity.angle())
	
	# East: -45° to 45°
	if angle_deg >= -45 and angle_deg < 45:
		return "side"  # East by default
	elif angle_deg >= 45 and angle_deg < 135:
		return "down"
	elif angle_deg >= -135 and angle_deg < -45:
		return "up"
	else:
		return "side"  # West will flip later

func update_animation(enemy_velocity: Vector2) -> void:
	# Decide direction
	if enemy_velocity.length() > 0.1:
		facing_direction = move_velocity.normalized()

	# Determine which animation to play based on facing_direction
	var dir_str = ""
	var angle_deg = rad_to_deg(facing_direction.angle())

	# Map 360° direction to animation
	if angle_deg >= -45 and angle_deg < 45:
		dir_str = "side"   # right
	elif angle_deg >= 45 and angle_deg < 135:
		dir_str = "down"
	elif angle_deg >= -135 and angle_deg < -45:
		dir_str = "up"
	else:
		dir_str = "side"   # left (we will flip)

	# Choose walk or idle
	var anim_name = ""
	if enemy_velocity.length() > 0.1:
		anim_name = "walk_" + dir_str
	else:
		anim_name = "idle_" + dir_str

	animation_player.play(anim_name)

	# Flip side sprite if facing left
	if dir_str == "side":
		sprite.flip_h = facing_direction.x < 0
	else:
		sprite.flip_h = false

func _on_damage_hitbox_area_entered(area: Area2D) -> void:
	if not area.is_in_group("player_hurtbox"):
		return
	
	var player = area.get_parent()
	if player == null:
		return
	
	if player.has_method("take_damage"):
		player.take_damage(damage_dealt)
	
	# Compute knockback direction
	var direction_to_player = (player.global_position - global_position).normalized()

	# Knockback the player
	if player.has_method("apply_knockback"):
		player.apply_knockback(direction_to_player, 120)  # strength in pixels/sec

	# Knockback the enemy itself slightly
	apply_knockback(-direction_to_player * 0.5)  # small recoil
