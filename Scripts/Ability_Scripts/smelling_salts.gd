extends Node2D

signal smelling_salts_finished

@onready var sprite = $SmellingSaltsSprite


func _ready() -> void:
	sprite.play("vapor")
	await sprite.animation_finished
	queue_free()
