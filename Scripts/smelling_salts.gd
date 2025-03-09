extends Node2D

signal smelling_salts_finished

@onready var sprite = $SmellingSaltsSprite

func _ready() -> void:
	var vaporSignal = get_node("/root/Scene2-TilemapTesting/DungeonRooms/StartingRoom/PlayerDungeonSpawn/player")
	vaporSignal.launch_vapor.connect(_on_player_launch_vapor)
	pass
	hide()

# Called when player needs to launch vapor for smelling salts
func _on_player_launch_vapor(x: Variant, y: Variant) -> void:
	# Play vapor animation
	show()
	sprite.play("vapor")
	await sprite.animation_finished
	hide()
	
	# Signal the vapor animation is complete
	smelling_salts_finished.emit()
