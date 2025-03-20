extends CharacterBody2D

@export var speed = 150
@export var boosted_speed = 300
@export var acceleration = 900
@export var friction = 600
@export var direction_change_accel = 2000
@export var spells = ["grenade", "smelling_salts"]
@export var spell_cooldowns = [7, 12] # spell cooldown is seconds
@export var knife_damage = 10
@export var boosted_knife_damage = 20
@export var max_buff_duration = 10
@export var iframes = 60
@export var attack_chain_window = 20

@onready var death_label = $"CanvasLayer/DeathLabel"
@onready var sprite = $PlayerSprite
@onready var health = $"Health Component"
@onready var ui = $Camera2D/Ui
const GRENADE = preload("res://Scenes/Ability_Scenes/grenade2.tscn")
const KNIFE = preload("res://Scenes/Projectile_Scenes/knife.tscn")
const SALTS = preload("res://Scenes/Ability_Scenes/smelling_salts.tscn")
var isThrowing = false

var can_move = true
var can_turn = true
var animating = false
var current_spell_index = 0
var can_cast = [true, true]

var stats_boosted = false
var buff_timer = 0
var iframe_timer = 0

var attack_chain = 0
var chain_timer = 0

signal spell_key_released
signal launch_vapor(x, y)

func get_input(delta):
	var input_direction = Input.get_vector("left", "right", "up", "down")

	if input_direction != Vector2.ZERO && can_move:
		# Check if moving in the opposite direction
		if velocity.dot(input_direction) < 0:
			# Apply stronger acceleration when switching directions
			velocity = velocity.move_toward(input_direction * (boosted_speed if stats_boosted else speed), direction_change_accel * delta)
		else:
			# Normal acceleration
			velocity = velocity.move_toward(input_direction * (boosted_speed if stats_boosted else speed), acceleration * delta)
	else:
		# Apply friction when no input is given
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

func _input(event):
	if health.is_defeated:
		return
	
	# Change to next spell
	if event.is_action("scroll_down") && current_spell_index < spells.size() - 1:
		current_spell_index += 1
	# Change to previous spell
	if event.is_action("scroll_up") && current_spell_index > 0:
		current_spell_index -= 1
	
	# Cast a spell
	if !animating and event.is_action_pressed("spell"):
		# Casting animation is playing
		animating = true
		can_move = false
		
		# Play casting animation based on spell
		if (spells[current_spell_index] == "grenade" and can_cast[current_spell_index]):
			cooldown_spell(current_spell_index)
			await grenade_animation()
		elif (spells[current_spell_index] == "smelling_salts" and can_cast[current_spell_index]):
			cooldown_spell(current_spell_index)
			await smelling_salts_animation()
		
		# Casting animations finished
		can_move = true
		animating = false
	
	# Check when spellcasting button is released
	if event.is_action_released("spell"):
		spell_key_released.emit()
		
	if !animating and event.is_action("attack"):
		# Attacking animation is playing
		animating = true
		
		await attack_animation()
		
		# Casting animations finished
		animating = false

func _physics_process(delta):
	if health.is_defeated:
		return
	get_input(delta)
	move_and_slide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if health.is_defeated:
		if Input.is_action_just_pressed("restart"):
			get_tree().reload_current_scene()
		return
	var mouse_pos = get_global_mouse_position()
	var pos = global_position
	
	# Flip sprite based on mouse position
	if can_turn:
		sprite.flip_h = mouse_pos.x < pos.x
	
	# Walking/idle animation when no other stuff is going on
	if can_move and !animating:
		# Play animations based on movement
		if !velocity.is_zero_approx():
			sprite.play("walk")
		else:
			sprite.play("idle")
	
	# Decrements timer and removes buffs when timer runs out
	if stats_boosted:
		buff_timer -= delta
		if buff_timer <= 0:
			stats_boosted = false
	
	# Decrements invincibility frame timer
	if iframe_timer > 0:
		iframe_timer -= 1
		
	# Decrements attack chain timer
	if chain_timer > 0:
		chain_timer -= 1
		if chain_timer <= 0:
			attack_chain = 0

func grenade_animation():
	# Plays first half of throwing animation once
	sprite.play("throw_start")
	await sprite.animation_finished
	
	# Throwing idle if held down, finish if released
	if (Input.is_action_pressed("spell")):
		sprite.play("throw_idle")
		await spell_key_released
	sprite.play("throw_finish")
	_launch()
	await sprite.animation_finished
	
func smelling_salts_animation():
	# Locks turning
	can_turn = false
	var direction = -1 if sprite.flip_h else 1
	
	# Set vapor location to bottle top
	var offset_x = direction * 10
	var offset_y = -16
	
	sprite.play("smelling_salts")
	await sprite.animation_finished
	
	# Wait for vapor animation
	# Vapor animation works its that the offset was off the player by a wide margin
	var salts = SALTS.instantiate()
	
	salts.position.x = position.x + offset_x
	salts.position.y = position.y + offset_y
	
	get_parent().add_child(salts)
	
	stats_boosted = true
	buff_timer = max_buff_duration
	
	# Unlock turning
	can_turn = true
	
func attack_animation():
	# First knife throw
	if attack_chain == 0:
		sprite.play("basic_attack_1")
		await sprite.animation_finished
		_fire()
		sprite.play("basic_attack_2")
		await sprite.animation_finished
		chain_timer = attack_chain_window
		attack_chain = 1
	# Second knife throw
	elif attack_chain == 1:
		_fire()
		sprite.play("basic_attack_3")
		await sprite.animation_finished
		chain_timer = attack_chain_window
		attack_chain = 2
	# Third knife throw
	else:
		_fire()
		sprite.play("basic_attack_4")
		await sprite.animation_finished
		attack_chain = 0

func _ready():
	z_index = 1
	ui.set_health(health.MAX_HEALTH, health.MAX_HEALTH)
	ui.set_spell_0(spells[0])
	ui.set_spell_1(spells[1])

func _launch():
		if isThrowing: return
		
		isThrowing = true
		
		var startPosition = global_position
		var direction = -1 if sprite.flip_h else 1
		var targetPosition = Vector2(startPosition.x + 300 * direction, startPosition.y) - global_position
		
		var grenade = GRENADE.instantiate()
		grenade.targetPosition = targetPosition
		
		get_parent().add_child(grenade)
		grenade.global_position = global_position
		
		await get_tree().create_timer(0.1, false).timeout
		
		isThrowing = false

func _fire() :
	var knife = KNIFE.instantiate()
	if stats_boosted:
		knife.damage = boosted_knife_damage
	else:
		knife.damage = knife_damage
	
	add_child(knife)
	
func knockback(direction: Vector2, magnitude):
	velocity = direction * magnitude

func cooldown_spell(spell):
	can_cast[spell] = false
	ui.set_cooldown(spell)
	await get_tree().create_timer(spell_cooldowns[spell], false).timeout  # Wait for the set time
	can_cast[spell] = true
	ui.set_ready(spell)

func _on_health_component_health_change(character_newHealth: Variant) -> void:
	ui.set_health(character_newHealth, health.MAX_HEALTH)
	can_move = false
	animating = true
	iframe_timer = iframes
	sprite.play("hurt")
	await sprite.animation_finished
	animating = false
	can_move = true

func _on_health_component_destroyed() -> void:
	sprite.play("death")
	death_label.parse_bbcode("[center][color=red]You Died![/color]\nPress [color=yellow]'R'[/color] to Restart[/center]")
	death_label.visible = true  # Show the message
