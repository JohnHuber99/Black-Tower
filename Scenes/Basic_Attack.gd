extends CharacterBody2D
var bullet_path=preload("res://knife.tscn")
func _physics_process(delta):
	look_at(get_global_mouse_position())
	if Input.is_action_just_pressed("ui_accept"): 
		fire()
		
func fire() :
	var knife=bullet_path.instantiate()
	knife.dir=rotation
	knife.pos=global_position
	knife.rota=global_rotation
	get_parent().add_child(knife)
