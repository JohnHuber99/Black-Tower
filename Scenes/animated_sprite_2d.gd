extends AnimatedSprite2D

var casting = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	var pos = global_position
	
	# Flip sprite based on mouse position
	flip_h = mouse_pos.x < pos.x
	
	# Walking/idle animation when no other stuff is going on
	if get_parent().can_move:
		# Play animations based on movement
		if !get_parent().velocity.is_zero_approx():
			play("walk")
		else:
			play("idle")
			
func _input(event):
	if !casting and event.is_action_pressed("spell"):
		# Casting animation is playing
		casting = true
		get_parent().can_move = false
		
		# Play casting animation based on spell
		if (get_parent().spells[get_parent().current_spell_index] == "grenade"):
			await grenade_animation()
		elif (get_parent().spells[get_parent().current_spell_index] == "smelling_salts"):
			await smelling_salts_animation()
		
		# Casting animations finished
		get_parent().can_move = true
		casting = false
		
			
			
func grenade_animation():
	# Plays first half of throwing animation once
	play("throw_start")
	await animation_finished
	
	# Throwing idle if held down, finish if released
	if (Input.is_action_pressed("spell")):
		play("throw_idle")
		await get_parent().spell_released
	play("throw_finish")
	await animation_finished
	
func smelling_salts_animation():
	play("smelling_salts")
	await animation_finished
	
