extends Node

class_name HealthComponent

@export var MAX_HEALTH: int = 60
var current_health: int
var is_defeated: bool = false

signal health_change(character_newHealth)
signal destroyed

func _ready():
	current_health = MAX_HEALTH

func damage_taken(amount: int):
	if is_defeated:
		return
	current_health = max(0, current_health - amount)
	health_change.emit(current_health)
	
	if current_health <= 0:
		destroy()
		
func heal(amount: int):
	if is_defeated:
		return
	current_health += amount
	health_change.emit(current_health)
	
func destroy():
	if is_defeated:
		return
	is_defeated = true
	destroyed.emit()
