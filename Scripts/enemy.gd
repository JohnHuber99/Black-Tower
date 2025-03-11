extends CharacterBody2D

@export var speed = 100
@export var attack_proximity = 75

@onready var sprite = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	var player = $"."
	# This should be whatever the player instance is
	if (get_node("../player") != null):
		player = get_node("../player")
	
	# Move in the direction of the player
	var direction = Vector2(player.position.x-position.x, player.position.y-position.y)
	if direction:
		direction /= direction.length()
		velocity = direction * speed
	move_and_slide()

func _process(delta):
	var player = $"."
	# This should be whatever the player instance is
	if (get_node("../player") != null):
		player = get_node("../player")
	
	var x_distance = position.x - player.position.x
	var y_distance = position.y - player.position.y
	
	# Face toward player
	sprite.flip_h = x_distance > 0
	
	# Attack if close enough to player
	var distance_to_player = sqrt(x_distance*x_distance + y_distance*y_distance)
	if (distance_to_player <= attack_proximity):
		sprite.play("attack")
		await sprite.animation_finished
	else:
		sprite.play("default")
