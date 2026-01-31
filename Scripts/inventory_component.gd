class_name InventoryComponent extends Node

signal coins_changed(new_amount: int)

var coins: int = 0

func add_coins(amount: int) -> void:
	coins += amount
	coins_changed.emit(coins)

func remove_coins(amount: int) -> bool:
	if coins < amount:
		return false
	
	coins -= amount
	coins_changed.emit(coins)
	return true
