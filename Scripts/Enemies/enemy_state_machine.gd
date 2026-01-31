class_name EnemyStateMachine extends Node

@export var initial_state : NodePath

var current_state : EnemyState
var enemy : Enemy

func _ready() -> void:
	enemy = owner as Enemy

	for child in get_children():
		if child is EnemyState:
			child.enemy = enemy
			child.state_machine = self

	if initial_state.is_empty():
		push_warning("EnemyStateMachine has no initial state path assigned.")
		return

	var first_state = get_node_or_null(initial_state)
	if first_state == null or not (first_state is EnemyState):
		push_error("Initial state path does not point to an EnemyState.")
		return

	change_state(first_state)

func change_state(new_state: EnemyState) -> void:
	if current_state == new_state:
		return

	if current_state:
		current_state.exit()

	current_state = new_state
	if current_state:
		current_state.enter()

func physics_update(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)
