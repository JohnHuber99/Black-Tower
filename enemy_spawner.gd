extends Node2D

@export var enemy_scene: PackedScene  # Assign Enemy.tscn in the Inspector
@onready var spawn_points: Array = get_children()  # Get all spawn points

func _ready():
	spawn_enemy()

func spawn_enemy():
	if enemy_scene and spawn_points.size() > 0:
		var spawn_point = spawn_points[randi() % spawn_points.size()]  # Random spawn point
		var enemy = enemy_scene.instantiate()  # Instantiate enemy
		enemy.global_position = spawn_point.global_position  # Set position
		add_child(enemy)  # Add enemy to the scene
