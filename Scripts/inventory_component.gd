class_name InventoryComponent extends Node

signal coins_changed(new_amount: int)
signal item_added(item_id: String, amount: int)
signal item_removed(item_id: String, amount: int)

var coins: int = 0
var items := {} # Dictionary<String, int>

func add_coins(amount: int) -> void:
	coins += amount
	coins_changed.emit(coins)

func remove_coins(amount: int) -> bool:
	if coins < amount:
		return false
	
	coins -= amount
	coins_changed.emit(coins)
	return true

func add_item(item_id: String, amount := 1) -> void:
	items[item_id] = items.get(item_id, 0) + amount
	item_added.emit(item_id, items[item_id])

func remove_item(item_id: String, amount := 1) -> bool:
	if not items.has(item_id):
		return false
	if items[item_id] < amount:
		return false

	items[item_id] -= amount
	if items[item_id] <= 0:
		items.erase(item_id)

	item_removed.emit(item_id, items.get(item_id, 0))
	return true
