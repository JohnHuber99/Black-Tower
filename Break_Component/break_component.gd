extends Node

class_name BreakComponent

@export var MAX_BREAK_BAR: int = 50
var current_break_bar: int
var is_broken: bool = false
var damage_resistance: float = 1.0

signal broken
signal break_damage(amount, type)
signal break_change(newBreak)

func _ready():
	current_break_bar = MAX_BREAK_BAR

func break_taken(amount: int, type):
	if is_broken:
		if type != null:
			break_damage.emit(amount, type)
		return
	var adjusted_damage = int(amount * damage_resistance)
	current_break_bar = max(0, current_break_bar - adjusted_damage)
	break_change.emit(current_break_bar)
	
	if current_break_bar <= 0:
		await destroy()
		if type != null:
			break_damage.emit(amount, type)
	
func destroy():
	if is_broken:
		return
	is_broken = true
	broken.emit()
