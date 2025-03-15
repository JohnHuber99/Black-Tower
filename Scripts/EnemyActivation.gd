extends Area2D

signal enemy_activated
signal enemy_deactivated

func _ready():
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)
	
func _on_body_entered(body):
	if body.is_in_group("player"):  # Ensure the player is in a "player" group
		emit_signal("enemy_activated")

func _on_body_exited(body):
	if body.is_in_group("player"):  # Ensure the player is in a "player" group
		emit_signal("enemy_deactivated")
