extends CharacterBody2D


const SPEED = 100.0

##i added the player back sorry alan
@onready var player = $"."

func _physics_process(delta: float) -> void:

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Vector2(player.position.x-position.x, player.position.y-position.y)
	if direction:
		direction /= direction.length()
		velocity = direction * SPEED
	move_and_slide()
