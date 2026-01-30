class_name State_Attack extends State

var attacking : bool = false

@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"
@onready var idle: State_Idle = $"../Idle"
@onready var walk: State_Walk = $"../Walk"


func Enter() -> void:
	player.update_animation("attack")
	spawn_sword()
	animation_player.animation_finished.connect(EndAttack)
	attacking = true
	pass


func Exit() -> void:
	animation_player.animation_finished.disconnect(EndAttack)
	attacking = false
	pass


func Process(_delta : float) -> State:	
	player.velocity = Vector2.ZERO
	
	if attacking == false:
		if player.direction == Vector2.ZERO:
			return idle
		else:
			return walk
	
	return null


func Physics(_delta : float) -> State:
	return null


func HandleInput(_event : InputEvent) -> State:
	return null


func EndAttack(_newAnimationName : String) -> void:
	attacking = false


func spawn_sword():
	var sword = player.sword_scene.instantiate()
	player.add_child(sword)
	sword.position = player.get_sword_offset(player.cardinal_direction)
	sword.set_draw_order(player.cardinal_direction)
	sword.play_slash(player.cardinal_direction)
