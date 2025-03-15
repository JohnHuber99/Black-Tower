extends Area2D

func _ready():
	connect("body_entered", _on_body_entered)
	
func _on_body_entered(body):
	var player = get_node("/root/Main/player")
	if body.is_in_group("player"):  # Ensure the player is in a "player" group
		match get_parent().type:
			"right": player.position += Vector2(58, 0)
			"left": player.position += Vector2(-58, 0)
			"up": player.position += Vector2(0, -58)
			"down": player.position += Vector2(0, 58)
				
