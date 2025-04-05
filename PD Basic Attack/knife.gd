extends CharacterBody2D

class_name Knife

@export var SPEED = 400 # Value is subject to change 
@export var damage = 10
@export var break_effect = 10

var dir : float

func _ready():
	look_at(get_global_mouse_position())
	dir = rotation
	add_collision_exception_with(get_parent())
	
func _physics_process(delta):
	velocity = Vector2(SPEED,0).rotated(dir)
	var collision = move_and_collide(velocity*delta)
	if collision:
		var collider = collision.get_collider()
		if (collider is Enemy):
			collider.health.damage_taken(damage)
			collider.break_bar.break_taken(break_effect, null)
		queue_free()
