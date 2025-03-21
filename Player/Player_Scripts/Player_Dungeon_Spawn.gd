extends Marker2D
const PLAYER = preload("res://Player/player.tscn")

func _ready():
	var main_scene = get_node("/root/Run/CurrentView/Main")
	var player_instance = PLAYER.instantiate()
	player_instance.global_position = global_position  # Set initial position
	player_instance.visible = true
	player_instance.z_index = 1  # Make sure the player is in front
	player_instance.name = "player"
	if player_instance.get_parent() != null:
		player_instance.get_parent().remove_child(player_instance)
	main_scene.add_child.call_deferred(player_instance)
	
