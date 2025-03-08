extends Node2D

signal smelling_salts_finished

@onready var sprite = $SmellingSaltsSprite

func _ready() -> void:
	pass
	hide()

# Called when player needs to launch vapor for smelling salts
func _on_player_launch_vapor(x: Variant, y: Variant) -> void:
	# Go to player location
	position.x = x
	position.y = y
	
	# Play vapor animation
	show()
	sprite.play("vapor")
	await sprite.animation_finished
	hide()
	
	# Signal the vapor animation is complete
	smelling_salts_finished.emit()
	
