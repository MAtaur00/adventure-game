class_name Player extends CharacterBody2D


var cardinal_direction := Vector2.DOWN
var direction := Vector2.ZERO
@export var move_speed := 90.0

@export var invincibility_time :float = 1.0
var is_invincible: bool = false
var respawn_point

@onready var invincibility_timer: Timer = $InvincibilityTimer

@onready var hurtbox: Area2D = $Hurtbox
signal died

@onready var hearts_ui = get_tree().get_first_node_in_group("hearts_ui")
@onready var health: PlayerHealthComponent = $HealthComponent

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var state_machine: PlayerStateMachine = $StateMachine

var input_locked := false
var movement_locked := false
var actions_locked := false

var can_slash : bool = true
@export var slash_time : float = 0.2
@export var weapon_damage : float = 1.0
@export var sword_scene: PackedScene

@onready var game_controller: GameController = get_node("/root/Main/GameController")

var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_decay: float = 500.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("player")
	var camera := get_viewport().get_camera_2d()
	
	health.damaged.connect(_on_damaged)
	health.died.connect(_on_died)
	
	respawn_point = global_position
	
	camera.pan_started.connect(func():
		input_locked = true
		movement_locked = true
		actions_locked = true)
	
	camera.pan_finished.connect(func():
		input_locked = false
		movement_locked = false
		actions_locked = false)
	
	state_machine.Initialize(self)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if input_locked:
		sprite.visible = true
		return
	
	if is_invincible:
		var t = int(Time.get_ticks_msec() / 100) % 2
		sprite.visible = t == 0
	else:
		sprite.visible = true
	
	direction = Vector2(Input.get_axis("moveLeft", "moveRight"), Input.get_axis("moveUp", "moveDown")).normalized()
	
	# Apply knockback
	velocity = direction * move_speed + knockback_velocity
	if not movement_locked:
		move_and_slide()
	
	# Decay knockback
	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_decay * delta)


func _physics_process(_delta: float) -> void:
	if input_locked:
		velocity = Vector2.ZERO
		move_and_slide()
		update_animation("idle")
		return

func set_direction() -> bool:
	
	var new_direction : Vector2 = cardinal_direction
	if direction == Vector2.ZERO:
		return false
	
	if direction.y == 0:
		new_direction = Vector2.LEFT if direction.x < 0 else Vector2.RIGHT
	elif direction.x == 0:
		new_direction = Vector2.UP if direction.y < 0 else Vector2.DOWN
	
	if new_direction == cardinal_direction:
		return false
	
	cardinal_direction = new_direction
	sprite.scale.x = -1 if cardinal_direction == Vector2.LEFT else 1
	
	return true


func update_animation(state : String) -> void:
	animation_player.play(state + "_" + anim_direction())
	pass

func anim_direction() -> String:
	
	if cardinal_direction == Vector2.DOWN:
		return "down"
	elif cardinal_direction == Vector2.UP:
		return "up"
	else:
		return "side"


func get_sword_offset(dir: Vector2) -> Vector2:
	match dir:
		Vector2.UP:
			return Vector2(0, -2)
		Vector2.DOWN:
			return Vector2(0, 3)
		Vector2.LEFT:
			return Vector2(0, 7)
		Vector2.RIGHT:
			return Vector2(0, 7)
	
	return Vector2.ZERO

func apply_knockback(knock_direction: Vector2, strength: float) -> void:
	knockback_velocity = knock_direction.normalized() * strength

func take_damage(amount: int):
	if is_invincible:
		return
	
	health.take_damage(amount)
	
	start_invincibility()

func _on_hurtbox_area_entered(area: Area2D):
	if area.is_in_group("enemyHurtbox"):
		var enemy = area.get_parent()
		take_damage(enemy.damage)

func start_invincibility():
	is_invincible = true
	hurtbox.monitoring = false
	invincibility_timer.start()


func _on_invincibility_timer_timeout() -> void:
	is_invincible = false
	hurtbox.monitoring = true

func _on_damaged(_amount: int) -> void:
	#flash_white()
	pass

func _on_died() -> void:
	died.emit()

func collect_coin(amount: int):
	game_controller.add_coins(amount)
