extends CharacterBody2D

class_name Enemy

@export var speed = 150
@export var dash_speed = 5
@export var attack_proximity = 100
@export var damage = 20
@export var knockback = 400
@export var wait_time: float = 0.5  # Time (in seconds) to wait after collision
var is_waiting: bool = false  # Flag to track if waiting
var is_dashing: bool = false
var is_damaged: bool = false
var enemyActivation = false
var enemy_area : Node  
var collision : Object 
var last_direction

@onready var sprite = $AnimatedSprite2D
@onready var health = $"Health Component"
@onready var death_explosion = $CPUParticles2D
var player

func _ready() -> void:
	enemy_area = get_parent().get_parent().get_node("RoomArea")
	enemy_area.connect("enemy_activated", _on_enemy_activated)
	enemy_area.connect("enemy_deactivated", _on_enemy_deactivated)

func _physics_process(delta: float) -> void:
	if health.is_defeated:
		return
	if is_damaged:
		return
	if is_waiting or !enemyActivation:
		sprite.play("default")
		return  # Stop movement if in waiting state
	
	if sprite.animation == "default" and !is_dashing:
		slime_movement(delta)
	elif sprite.animation == "attack":
		slime_dash()

	if get_node_or_null("/root/Main/player"):  # Check if player node exists
		player = get_node("/root/Main/player")
	
	# Handle collision with the player
	if collision and sprite.animation == "attack":
		var collider = collision.get_collider()
		if collider == player:
			handle_player_collision()

func slime_movement(delta) -> void:
		# Calculate direction towards the player
	last_direction = (player.global_position - global_position).normalized()

	# Set motion vector
	var motion = last_direction * speed * delta
	
	# Move and detect collisions
	collision = move_and_collide(motion)

func slime_dash() -> void:
	# Set motion vector
	var motion = last_direction * dash_speed
	
	# Move and detect collisions
	collision =  move_and_collide(motion)
	

func handle_player_collision():
	if player.iframe_timer > 0:
		return
	
	var direction = player.position - position
	direction /= direction.length()
	player.knockback(direction, knockback)
	
	player.health.damage_taken(damage)

func pause_slime():
	is_waiting = true  # Stop movement
	await get_tree().create_timer(wait_time, false).timeout  # Wait for the set time
	is_waiting = false  # Resume movement

func _process(delta):
	# Stops moving during damage taken animation
	if is_waiting or health.is_defeated or is_damaged:
		return
	
	# This should be whatever the player instance is
	if (get_node("/root/Main/player") != null):
		player = get_node("/root/Main/player")
	
	var x_distance = global_position.x - player.global_position.x
	var y_distance = global_position.y - player.global_position.y
	
	# Face toward player
	sprite.flip_h = x_distance > 0
	
	# Attack if close enough to player
	if (global_position.distance_to(player.global_position) < attack_proximity and !is_dashing):
		is_dashing = true
		sprite.play("pause")
		await sprite.animation_finished
		last_direction = (player.global_position - global_position).normalized()
		sprite.play("attack")
		await sprite.animation_finished
		await pause_slime()
		is_dashing = false
	else:
		if !sprite.is_playing():
			sprite.play("default")

func _on_health_component_health_change(character_newHealth: Variant) -> void:
	is_damaged = true
	sprite.play("hurt")
	await sprite.animation_finished
	is_damaged = false
	
func _on_health_component_destroyed() -> void:
	sprite.play("death")
	death_explosion.emitting = true;
	await sprite.animation_finished
	queue_free()

func _on_enemy_activated() -> void:
	global_position = get_parent().global_position
	enemyActivation = true

func _on_enemy_deactivated() -> void:
	enemyActivation = false
	global_position = get_parent().global_position
