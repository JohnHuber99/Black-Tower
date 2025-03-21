extends Node2D

var enemyList: Array[Enemy]
var is_cleared = false
enum Type { EMPTY, NORMAL, START, FINAL, TREASURE, SHOP, LONG_H, BIG, BOSS}
var type: Type

func _ready() -> void:
	type = Type.NORMAL

func _on_enemy_spawned(enemy: Enemy):
	enemyList.append(enemy)
	enemy.connect("is_defeated", _on_is_defeated)

func _on_is_defeated() -> void:
	enemyList.pop_back()
	if enemyList.size() == 0:
		is_cleared = true

func get_is_cleared() -> bool:
	return is_cleared

func get_type() -> Type:
	return type
