extends Marker2D
const PLAYER = preload("res://Scenes/player.tscn")

func _ready():
	var main_scene = get_node("/root/Scene2-TilemapTesting")
	var player_instance = PLAYER.instantiate()
	player_instance.global_position = global_position  # Set initial position
	player_instance.visible = true
	player_instance.z_index = 1  # Make sure the player is in front
	player_instance.name = "player"
	main_scene.add_child(player_instance)
	add_child(player_instance)
	print(get_parent())
	print(main_scene)
		
	if player_instance.get_parent():
		print("✅ Player added successfully!")
	else:
		print("❌ Player not added!")
