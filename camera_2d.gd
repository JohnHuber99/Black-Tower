extends Camera2D

@export var pan_speed: float = 500.0

func _process(delta):
	var direction = Vector2.ZERO
	
	# The input mapping for camera movement is keys "IJKL"
	if Input.is_action_pressed("up_camera"): 
		direction.y -= 1
	if Input.is_action_pressed("down_camera"):
		direction.y += 1
	if Input.is_action_pressed("left_camera"):
		direction.x -= 1
	if Input.is_action_pressed("right_camera"):
		direction.x += 1
	
	if direction != Vector2.ZERO:
		position += direction.normalized() * pan_speed * delta
