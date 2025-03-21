extends Node2D

var enemyList: Array[Enemy]
var is_cleared = false
enum Type { EMPTY, NORMAL, START, FINAL, TREASURE, SHOP, LONG_H, BIG, BOSS}
var type: Type

func _ready() -> void:
	type = Type.BIG

func _on_enemy_spawned(enemy: Enemy):
	enemyList.append(enemy)
	enemy.connect("is_defeated", _on_is_defeated)

func _on_enemy_spawned_2(enemy: Enemy) -> void:
	enemyList.append(enemy)
	enemy.connect("is_defeated", _on_is_defeated)

func _on_enemy_spawned_3(enemy: Enemy) -> void:
	enemyList.append(enemy)
	enemy.connect("is_defeated", _on_is_defeated)

func _on_enemy_spawned_4(enemy: Enemy) -> void:
	enemyList.append(enemy)
	enemy.connect("is_defeated", _on_is_defeated)

func _on_enemy_spawned_5(enemy: Enemy) -> void:
	enemyList.append(enemy)
	enemy.connect("is_defeated", _on_is_defeated)

func _on_is_defeated() -> void:
	enemyList.pop_back()
	if enemyList.size() == 0:
		is_cleared = true
		print("Dungeon Cleared")
		Events.dungeon_cleared.emit()

func get_is_cleared() -> bool:
	return is_cleared

func get_type() -> Type:
	return type
