
extends Marker2D
const SLIME_ENEMY = preload("res://Slime_Enemy/slime_enemy.tscn")
const MUSHROOM_ENEMY = preload("res://Mushroom_Enemy/mushroom_enemy.tscn")
signal enemySpawned(enemy: Enemy)

func _ready() -> void:
	var enemy_instance = MUSHROOM_ENEMY.instantiate() if randf() > 0.5 else SLIME_ENEMY.instantiate()
	enemy_instance.z_index = 1  # Make sure the enemy is in front
	add_child.call_deferred(enemy_instance)
	enemySpawned.emit(enemy_instance)
