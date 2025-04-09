extends Enemy

func handle_physics_process(delta: float) -> void:
	if sprite.animation == "default" and !is_dashing:
		slime_movement(delta)
	elif sprite.animation == "attack":
		slime_dash()
		
	# Handle collision with the player
	if collision and sprite.animation == "attack":
		var collider = collision.get_collider()
		if collider == player:
			handle_damage_player()
			
func handle_process(delta):
	# Attack if close enough to player
	if (global_position.distance_to(player.global_position) < attack_proximity and !is_dashing):
		is_dashing = true
		sprite.play("pause")
		await sprite.animation_finished
		last_direction = (player.global_position - global_position).normalized()
		sprite.play("attack")
		await sprite.animation_finished
		await pause_enemy()
		is_dashing = false
	else:
		if !sprite.is_playing():
			sprite.play("default")
	
	
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
