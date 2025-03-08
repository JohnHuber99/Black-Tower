extends Marker2D
const PLAYER = preload("res://Scenes/player.tscn")

func _ready():
	var player_instance = PLAYER.instantiate()
	player_instance.global_position = global_position  # Set initial position
	player_instance.visible = true
	player_instance.z_index = 1  # Make sure the player is in front
	add_child(player_instance)
	
