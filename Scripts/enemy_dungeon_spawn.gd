extends Marker2D
const ENEMY = preload("res://Scenes/enemy.tscn")

@onready var main_scene = get_node("/root/Main")

func _ready() -> void:
	var enemy_instance = ENEMY.instantiate()
	enemy_instance.z_index = 1  # Make sure the enemy is in front
	add_child.call_deferred(enemy_instance)
