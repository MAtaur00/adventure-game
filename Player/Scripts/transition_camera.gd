extends Camera2D

const SCREEN_SIZE := Vector2(480, 272)
var cur_screen := Vector2.ZERO

@export var pan_duration := 0.35
var pan_tween: Tween

var initialized := false

signal pan_started
signal pan_finished

func _ready() -> void:
	set_as_top_level(true)
	
	cur_screen = (get_parent().global_position / SCREEN_SIZE).floor()
	global_position = cur_screen * SCREEN_SIZE + SCREEN_SIZE * 0.5
	initialized = true


func _physics_process(delta):
	var parent_screen : Vector2 = (get_parent().global_position / SCREEN_SIZE).floor()
	if parent_screen != cur_screen:
		_update_screen(parent_screen)


func _update_screen( new_screen : Vector2 ):
	cur_screen = new_screen
	var target_position := cur_screen * SCREEN_SIZE + SCREEN_SIZE * 0.5
	
	if not initialized:
		global_position = target_position
		return
	
	# Cancel any active tween
	if pan_tween and pan_tween.is_running():
		pan_tween.kill()
	
	pan_started.emit()
	
	# Create new tween
	pan_tween = create_tween()
	pan_tween.set_trans(Tween.TRANS_SINE)
	pan_tween.set_ease(Tween.EASE_IN_OUT)
	
	pan_tween.tween_property(self, "global_position", target_position, pan_duration)
	
	pan_tween.finished.connect(func(): pan_finished.emit())

func snap_to_position(world_position: Vector2) -> void:
	initialized = false
	cur_screen = (world_position / SCREEN_SIZE).floor()
	global_position = cur_screen * SCREEN_SIZE + SCREEN_SIZE * 0.5
	initialized = true

func _process(delta: float) -> void:
	pass
