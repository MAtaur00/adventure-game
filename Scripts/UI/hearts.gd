extends HBoxContainer

@export var full_heart: Texture2D
@export var half_heart: Texture2D
@export var empty_heart: Texture2D

var heartbeat_timer: Timer
var heartbeat_interval := 0.8

var player
var health_component

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() == 0:
		push_error("No player found for Hearts UI!")
		return
	
	player = players[0]
	health_component = player.health  # HealthComponent node
	health_component.health_changed.connect(update_hearts)
	
	call_deferred("_create_heartbeat_timer")
	
	call_deferred("_update_hearts_initial")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_hearts(current_health: int, max_health: int) -> void:
	var heart_count := int(ceil(max_health / 2.0))
	_ensure_heart_slots(heart_count)

	for i in range(min(get_child_count(), heart_count)):
		var heart := get_child(i) as TextureRect
		if heart == null:
			continue
		
		var heart_health := current_health - (i * 2)

		var new_texture: Texture2D
		if heart_health >= 2:
			new_texture = full_heart
		elif heart_health == 1:
			new_texture = half_heart
		else:
			new_texture = empty_heart

		# Animate if the heart changed
		if heart.texture != new_texture:
			heart.texture = new_texture
			_animate_heart_pop(heart)
	
	if heartbeat_timer:
		heartbeat_timer.stop()
		if current_health == 1:
			heartbeat_timer.wait_time = heartbeat_interval / 2
		else:
			heartbeat_timer.wait_time = heartbeat_interval
		heartbeat_timer.start()

func _ensure_heart_slots(count: int) -> void:
	var current_count = get_child_count()
	
	# Add missing hearts
	for i in range(current_count, count):
		var heart := TextureRect.new()
		
		# Set fallback size
		var heart_size = full_heart.get_size()
		if heart_size == Vector2.ZERO:
			heart_size = Vector2(16, 16)
		heart.custom_minimum_size = heart_size
		
		heart.size_flags_horizontal = Control.SIZE_FILL
		heart.size_flags_vertical = Control.SIZE_FILL
		heart.stretch_mode = TextureRect.STRETCH_KEEP
		heart.texture = empty_heart
		
		add_child(heart)
	
	# Remove extra hearts if any
	while get_child_count() > count:
		get_child(get_child_count() - 1).queue_free()
	
	call_deferred("queue_sort")

func _animate_heart_pop(heart: TextureRect) -> void:
	if heart == null:
		return
	
	# Reset scale first
	heart.scale = Vector2.ONE

	# Scale up
	var tween = create_tween()
	tween.tween_property(heart, "scale", Vector2(1.3, 1.3), 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	# Then scale back down
	tween.tween_property(heart, "scale", Vector2(1, 1), 0.1).set_delay(0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)

	tween.play()


func _on_heartbeat() -> void:
	if not is_instance_valid(health_component):
		return
	
	var current_hp: int = health_component.current_health
	var max_hp: int = health_component.max_health
	var heart_count: int = int(ceil(max_hp / 2.0))
	
	if current_hp <= 2:  # Low-health threshold
		for i in range(min(get_child_count(), heart_count)):
			var heart := get_child(i) as TextureRect
			if heart == null:
				continue

			var heart_health: int = current_hp - (i * 2)
			if heart_health > 0:
				_animate_heart_pop(heart)


func _update_hearts_initial():
	if health_component:
		update_hearts(health_component.current_health, health_component.max_health)

func _create_heartbeat_timer():
	heartbeat_timer = Timer.new()
	heartbeat_timer.wait_time = heartbeat_interval
	if health_component.current_health == 1:
		heartbeat_timer.wait_time = heartbeat_interval / 2
	heartbeat_timer.one_shot = false
	heartbeat_timer.autostart = true
	get_tree().get_root().add_child(heartbeat_timer)
	heartbeat_timer.timeout.connect(_on_heartbeat)
