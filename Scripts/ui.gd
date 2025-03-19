extends Node2D

@export var z_layer = 2

@onready var health = $Health/Label
@onready var mana = $Mana/Label

func _ready() -> void:
	z_index = z_layer

func set_health(current, max):
	health.text = str(current, "/", max)

func set_mana(current, max):
	mana.text = str(current, "/", max)
