extends Node

class_name CoinComponent

@export var coin_value: int = 1
var total_coins: int = 0

signal coins_collected(new_total: int)

@onready var sprite = $CoinSpriteAnimation
@onready var area = $Area2D

func _ready() -> void:
	sprite.play("default")
	area.connect("body_entered", _on_body_entered)

func _on_body_entered(body):
	if body is CharacterBody2D and body.has_method("collect_coin"):
		body.collect_coin(coin_value)
		queue_free()  # Remove coin from scene

func collect():
	total_coins += coin_value
	coins_collected.emit(total_coins)

func reset():
	total_coins = 0
	coins_collected.emit(total_coins)
