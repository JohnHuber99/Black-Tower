extends CharacterBody2D

@export var SPEED = 400 # Value is subject to change 

var dir : float
var spawnPos : Vector2

func _ready():
	global_position = spawnPos
	look_at(get_global_mouse_position())
	dir = rotation
	
func _physics_process(delta):
	velocity = Vector2(SPEED,0).rotated(dir)
	move_and_slide()
