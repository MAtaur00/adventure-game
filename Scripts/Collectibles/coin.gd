extends Area2D

@export var value: int = 1

func _ready() -> void:
	
	var final_scale = Vector2.ONE
	
	scale = Vector2.ZERO
	
	var tween = create_tween()
	tween.tween_property(self, "scale", final_scale, 0.15)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
	
	# Make collision shape match sprite size
	if $CollisionShape2D.shape is CircleShape2D:
		$CollisionShape2D.shape.radius *= 0.5
	
	connect("area_entered", _on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if not area.is_in_group("player_hurtbox"):
		return
	
	var player = area.get_parent()
	if player == null:
		return
	else:
		player.add_coins(value)
		queue_free()
