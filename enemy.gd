extends CharacterBody2D

@export var speed = 100
@export var attack_proximity = 100

##i added the player back sorry alan
@onready var player = $"../player"
@onready var sprite = $AnimatedSprite2D

func _physics_process(delta: float) -> void:

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Vector2(player.position.x-position.x, player.position.y-position.y)
	if direction:
		direction /= direction.length()
		velocity = direction * speed
	move_and_slide()

func _process(delta):
	var x_distance = position.x - player.position.x
	var y_distance = position.y - player.position.y
	
	sprite.flip_h = x_distance > 0
	
	var distance_to_player = sqrt(x_distance*x_distance + y_distance*y_distance)
	if (distance_to_player <= attack_proximity):
		sprite.play("attack")
		await sprite.animation_finished
	else:
		sprite.play("default")
