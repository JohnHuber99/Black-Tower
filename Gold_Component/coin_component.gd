extends Node2D
class_name CoinComponent

@export var coin_value: int = 1

@onready var sprite = $CoinSpriteAnimation
@onready var area = $Area2D
@onready var audio_player = $AudioStreamPlayer

func _ready() -> void:
	sprite.play("default")
	area.connect("body_entered", _on_body_entered)

func _on_body_entered(body):
	if body is CharacterBody2D and body.has_method("collect_coin"):
		body.collect_coin(coin_value)
		sprite.hide()
		audio_player.play()
		audio_player.finished.connect(queue_free)
