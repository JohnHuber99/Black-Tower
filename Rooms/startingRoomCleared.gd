extends Node2D

var enemyList: Array[Enemy]
var is_cleared = true
enum Type { EMPTY, NORMAL, START, FINAL, TREASURE, SHOP, LONG_H, BIG, BOSS}
var type: Type

func _ready() -> void:
	type = Type.START

func get_is_cleared() -> bool:
	return is_cleared

func get_type() -> Type:
	return type
