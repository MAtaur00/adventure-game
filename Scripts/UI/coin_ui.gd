class_name CoinUI extends CanvasLayer 

@onready var coin_label: Label = $VBoxContainer/CoinAmount
@onready var coin_icon: TextureRect = $VBoxContainer/CoinIcon

var coin_count: int = 0

func _ready() -> void:
	coin_label.text = str(coin_count)

func set_coins(amount: int) -> void:
	coin_count = amount
	coin_label.text = str(coin_count)

func add_coins(amount: int) -> void:
	set_coins(coin_count + amount)
