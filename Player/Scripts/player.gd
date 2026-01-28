class_name Player extends CharacterBody2D


var cardinal_direction := Vector2.DOWN
var direction := Vector2.ZERO

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var state_machine: PlayerStateMachine = $StateMachine

var can_slash : bool = true
@export var slash_time : float = 0.2
@export var weapon_damage : float = 1.0
@export var sword_scene: PackedScene


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	state_machine.Initialize(self)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	#direction.x = Input.get_action_strength("moveRight") - Input.get_action_strength("moveLeft")
	#direction.y = Input.get_action_strength("moveDown") - Input.get_action_strength("moveUp")
	
	direction = Vector2(Input.get_axis("moveLeft", "moveRight"), Input.get_axis("moveUp", "moveDown")).normalized()
	
	pass


func _physics_process(_delta: float) -> void:
	move_and_slide()


func SetDirection() -> bool:
	
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


func UpdateAnimation(state : String) -> void:
	
	animation_player.play(state + "_" + AnimDirection())
	
	pass


func AnimDirection() -> String:
	
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
