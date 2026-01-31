class_name PlayerHealthComponent extends Node

signal health_changed(current: int, max: int)
signal damaged(amount: int)
signal healed(amount: int)
signal died

@export var max_health: int = 6
var current_health: int

func _ready() -> void:
	current_health = max_health
	emit_signal("health_changed", current_health, max_health)

func take_damage(amount: int) -> void:
	if amount <= 0:
		return

	current_health = max(current_health - amount, 0)
	emit_signal("damaged", amount)
	emit_signal("health_changed", current_health, max_health)

	if current_health == 0:
		emit_signal("died")

func heal(amount: int) -> void:
	if amount <= 0:
		return

	current_health = min(current_health + amount, max_health)
	emit_signal("healed", amount)
	emit_signal("health_changed", current_health, max_health)

func increase_max_health(amount: int, heal_to_full := true) -> void:
	if amount <= 0:
		return

	max_health += amount

	if heal_to_full:
		current_health = max_health
	else:
		current_health = min(current_health, max_health)

	emit_signal("health_changed", current_health, max_health)

func reset():
	current_health = max_health
	emit_signal("health_changed", current_health, max_health)
