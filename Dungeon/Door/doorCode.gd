extends Area2D
enum { EMPTY, NORMAL, START, FINAL, TREASURE, SHOP, LONG_H, BIG, BOSS}

func _ready():
	connect("body_entered", _on_body_entered)
	
func _on_body_entered(body):
	var player = get_node("/root/Run/CurrentView/Main/player")
	var room = get_parent().get_parent()
	if body.is_in_group("player") and room.get_is_cleared():  # Ensure the player is in a "player" group
		match get_parent().type:
			"right": player.global_position += Vector2(65, 0)
			"left": player.global_position += Vector2(-65, 0)
			"up": player.global_position += Vector2(0, -110)
			"down": player.global_position += Vector2(0, 110)
				
