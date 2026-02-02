extends CanvasLayer

@export var inventory: InventoryComponent
@onready var coins_label: Label = $Panel/InventoryUI/CoinsLabel

func _ready():
	visible = false
	coins_label.text = str(inventory.coins)
	inventory.coins_changed.connect(_on_coins_changed)

func toggle_pause():
	var paused := not get_tree().paused
	get_tree().paused = paused
	visible = paused

func _on_coins_changed(amount: int):
	coins_label.text = str(amount)
