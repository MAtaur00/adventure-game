class_name HealthComponent extends Node

signal damaged(amount: float, hit_direction: Vector2)
signal died

@export var max_health : float = 3.0
var current_health : float

func _ready() -> void:
	current_health = max_health

func take_damage(amount: float, hit_direction: Vector2 = Vector2.ZERO) -> void:
	current_health -= amount
	damaged.emit(amount, hit_direction)

	if current_health <= 0.0:
		died.emit()
