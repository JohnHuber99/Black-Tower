extends CharacterBody2D

@export var speed = 150
@export var boosted_speed = 300
@export var acceleration = 900
@export var friction = 600
@export var direction_change_accel = 2000
@export var spells = ["grenade", "smelling_salts"]
@export var max_buff_duration = 10

@onready var sprite = $PlayerSprite

var can_move = true
var can_turn = true
var casting = false
var current_spell_index = 0

var stats_boosted = false
var buff_timer = 0

signal spell_key_released
signal launch_vapor(x, y)
signal spell_completed

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
	# Change to next spell
	if event.is_action("scroll_down") && current_spell_index < spells.size() - 1:
		current_spell_index += 1
	# Change to previous spell
	if event.is_action("scroll_up") && current_spell_index > 0:
		current_spell_index -= 1
	
	# Cast a spell
	if !casting and event.is_action_pressed("spell"):
		# Casting animation is playing
		casting = true
		can_move = false
		
		# Play casting animation based on spell
		if (spells[current_spell_index] == "grenade"):
			await grenade_animation()
		elif (spells[current_spell_index] == "smelling_salts"):
			await smelling_salts_animation()
		
		# Casting animations finished
		can_move = true
		casting = false
	
	# Check when spellcasting button is released
	if event.is_action_released("spell"):
		spell_key_released.emit()

func _physics_process(delta):
	get_input(delta)
	move_and_slide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var mouse_pos = get_global_mouse_position()
	var pos = global_position
	
	# Flip sprite based on mouse position
	if can_turn:
		sprite.flip_h = mouse_pos.x < pos.x
	
	# Walking/idle animation when no other stuff is going on
	if can_move:
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

# Boost stats and release sprite after vapor animation is finished
func _on_smelling_salts_finished() -> void:
	stats_boosted = true
	buff_timer = max_buff_duration
	spell_completed.emit()

func grenade_animation():
	# Plays first half of throwing animation once
	sprite.play("throw_start")
	await sprite.animation_finished
	
	# Throwing idle if held down, finish if released
	if (Input.is_action_pressed("spell")):
		sprite.play("throw_idle")
		await spell_key_released
	sprite.play("throw_finish")
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
	launch_vapor.emit(position.x + 90, position.y + 40)
	await spell_completed
	
	# Unlock turning
	can_turn = true

# Signal connection works but for some reason the function doesn't call and print Player Received Signal or set the position to starting room
func _on_dungeon_rooms_start_room_pos(start_x: int, start_y: int) -> void:
	print("Player received signal!", start_x, start_y)
	position = Vector2(start_x, start_y)
	pass # Replace with function body.

func _ready():
	var dungeon = get_node("/root/Scene2-TilemapTesting/DungeonRooms")  # Adjust the path to your DungeonRoom node
	if dungeon:
		dungeon.start_room_pos.connect(_on_dungeon_rooms_start_room_pos)  # Connect the signal
		if dungeon.is_connected("start_room_pos", _on_dungeon_rooms_start_room_pos):
			print("Player successfully connected to DungeonRoom signal!")
		else:
			print("Failed to connect to signal!")
	else:
		print("DungeonRoom node not found!")
