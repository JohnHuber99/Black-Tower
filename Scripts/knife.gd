extends CharacterBody2D

class_name Knife

@export var SPEED = 400 # Value is subject to change 
@export var damage = 20 # Value is subject to change 

var dir : float
var spawnPos : Vector2

func _ready():
	global_position = spawnPos
	look_at(get_global_mouse_position())
	dir = rotation
	add_collision_exception_with(get_node("../player"))
	
func _physics_process(delta):
	velocity = Vector2(SPEED,0).rotated(dir)
	var collision = move_and_collide(velocity*delta)
	if collision:
		var collider = collision.get_collider()
		if (collider is Enemy):
			collider.health.damage_taken(damage)
		queue_free()
