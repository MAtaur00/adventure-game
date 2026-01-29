extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D

@export var sword_damage : float = 1.0

var hit_bodies := {}
var attack_direction := Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func PlaySlash(direction : Vector2) -> void:
	attack_direction = direction
	match direction:
		Vector2.UP:
			animation_player.play("slash_up")
		Vector2.DOWN:
			animation_player.play("slash_down")
		Vector2.RIGHT:
			animation_player.play("slash_right")
		Vector2.LEFT:
			animation_player.play("slash_left")
	
	pass

func SlashFinished() -> void:
	queue_free()
	pass

func set_draw_order(direction: Vector2) -> void:
	match direction:
		Vector2.DOWN:
			z_index = 2      # in front of player
		Vector2.UP:
			z_index = 0     # behind player
		Vector2.LEFT, Vector2.RIGHT:
			z_index = 0


func _on_body_entered(body: Node2D) -> void:
	if body in hit_bodies:
		return
	
	if body is Enemy:
		print("hit!")
		var hit_dir = (body.global_position - global_position).normalized()
		body.health.take_damage(sword_damage, hit_dir)
		hit_bodies[body] = true
	pass # Replace with function body.


func deal_damage(enemy: Enemy, damage: float, hit_dir: Vector2):
	enemy.health.take_damage(damage, hit_dir)
	enemy.apply_knockback(hit_dir)
