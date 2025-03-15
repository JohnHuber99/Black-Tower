extends Area2D

signal enemy_activated

func _ready():
	connect("body_entered", _on_body_entered)
	
func _on_body_entered(body):
	var player = get_node("/root/Main/player")
	if body.is_in_group("player"):  # Ensure the player is in a "player" group
		emit_signal("enemy_activated")
