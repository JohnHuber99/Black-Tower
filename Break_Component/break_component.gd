extends Node

class_name BreakComponent

@export var MAX_BREAK_BAR: int = 30
var current_break_bar: int
var is_broken: bool = false

signal broken

func _ready():
	current_break_bar = MAX_BREAK_BAR

func break_taken(amount: int):
	if is_broken:
		return
	current_break_bar = max(0, current_break_bar - amount)
	
	if current_break_bar <= 0:
		destroy()
	
func destroy():
	if is_broken:
		return
	is_broken = true
	broken.emit()
