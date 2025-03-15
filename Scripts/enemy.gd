extends CharacterBody2D

class_name Enemy

@export var speed = 100
@export var attack_proximity = 75
@export var damage = 20
@export var knockback = 400
@export var wait_time: float = 0.5  # Time (in seconds) to wait after collision
var is_waiting: bool = false  # Flag to track if waiting
var enemyActivation = false
var enemy_area : Node  

@onready var sprite = $AnimatedSprite2D
@onready var health = $"Health Component"
var player

func _ready() -> void:
	enemy_area = get_parent().get_node("RoomArea")
	enemy_area.connect("enemy_activated", _on_enemy_activated)
	enemy_area.connect("enemy_deactivated", _on_enemy_deactivated)

func _physics_process(delta: float) -> void:
	if is_waiting or !enemyActivation or health.is_defeated:
		return  # Stop movement if in waiting state

	if get_node_or_null("/root/Main/player"):  # Check if player node exists
		player = get_node("/root/Main/player")

	# Calculate direction towards the player
	var direction = (player.global_position - global_position).normalized()

	# Set motion vector
	var motion = direction * speed * delta
	
	# Stops moving during damage taken animation
	# Move and detect collisions
	var collision = move_and_collide(motion)

	# Handle collision with the player
	if collision:
		var collider = collision.get_collider()
		if collider == player:
			handle_player_collision()

func handle_player_collision():
	if player.iframe_timer > 0:
		return
	
	var direction = player.position - position
	direction /= direction.length()
	player.knockback(direction, knockback)
	
	player.health.damage_taken(damage)

func pause_slime():
	is_waiting = true  # Stop movement
	await get_tree().create_timer(wait_time).timeout  # Wait for the set time
	is_waiting = false  # Resume movement

func _process(delta):
	# Stops moving during damage taken animation
	if is_waiting or health.is_defeated:
		return
	
	# This should be whatever the player instance is
	if (get_node("/root/Main/player") != null):
		player = get_node("/root/Main/player")
	
	var x_distance = position.x - player.position.x
	var y_distance = position.y - player.position.y
	
	# Face toward player
	sprite.flip_h = x_distance > 0
	
	# Attack if close enough to player
	var distance_to_player = sqrt(x_distance*x_distance + y_distance*y_distance)
	if (distance_to_player <= attack_proximity):
		sprite.play("attack")
		await sprite.animation_finished
		pause_slime()
	else:
		sprite.play("default")


func _on_health_component_health_change(character_newHealth: Variant) -> void:
	is_waiting = true
	sprite.play("hurt")
	await sprite.animation_finished
	is_waiting = false
	
func _on_health_component_destroyed() -> void:
	await sprite.animation_finished
	sprite.play("death")
	await sprite.animation_finished
	queue_free()

func _on_enemy_activated() -> void:
	enemyActivation = true

func _on_enemy_deactivated() -> void:
	enemyActivation = false
