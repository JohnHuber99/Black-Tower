extends Node

class_name CoinComponent

@export var coin_value: int = 1
var total_coins: int = 0

signal coins_collected(new_total: int)

@onready var sprite = $CoinSpriteAnimation

func _ready() -> void:
	sprite.play("default")

func collect():
	total_coins += coin_value
	coins_collected.emit(total_coins)

func reset():
	total_coins = 0
	coins_collected.emit(total_coins)
