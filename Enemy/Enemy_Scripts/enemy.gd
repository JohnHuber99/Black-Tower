extends CharacterBody2D

class_name Enemy

signal is_defeated

@export var max_health = 100
@export var max_break_bar = 50
@export var speed = 150
@export var dash_speed = 5
@export var attack_proximity = 100
@export var damage = 10
@export var knockback = 400
@export var wait_time: float = 0.5  # Time (in seconds) to wait after collision
@export var break_factor: float = 0.5  # Factor by which stats are reduced when broken
@export var dot_taken = 10 # How much damage over time is taken from plague
@export var dot_interval = 3 # How often damage over time from plague is taken in seconds

var is_waiting: bool = false  # Flag to track if waiting
var is_dashing: bool = false
var is_damaged: bool = false
var enemyActivation = false
var enemy_area : Node  
var collision : Object 
var last_direction
var take_dot = false
var break_damage_multiplier = 1

@onready var sprite = $AnimatedSprite2D
@onready var health = $"Health Component"
@onready var break_bar = $"Break Component"
@onready var death_explosion = $CPUParticles2D
@onready var health_ui = $BarFrame/HealthBar
@onready var break_ui = $BarFrame/BreakBar
@onready var bar_ui = $BarFrame

var player

func _ready() -> void:
	enemy_area = get_parent().get_parent().get_node("RoomArea")
	enemy_area.connect("enemy_activated", _on_enemy_activated)
	enemy_area.connect("enemy_deactivated", _on_enemy_deactivated)

# Override in subclass
func handle_physics_process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	if health.is_defeated:
		return
	if is_damaged:
		return
	if is_waiting or !enemyActivation:
		sprite.play("default")
		return  # Stop movement if in waiting state

	if get_node_or_null("/root/Run/CurrentView/Main/player"):  # Check if player node exists
		player = get_node("/root/Run/CurrentView/Main/player")
		
	handle_physics_process(delta)
	

func handle_damage_player():
	if player.iframe_timer > 0:
		return
	
	var direction = player.position - position
	direction /= direction.length()
	player.knockback(direction, knockback)
	
	player.health.damage_taken(damage)

func damage_over_time():
	take_dot = false
	health.damage_taken(dot_taken)
	await get_tree().create_timer(dot_interval, false).timeout
	take_dot = true

# Override in subclass
func handle_process(delta: float) -> void:
	pass

func _process(delta):
	# Stops moving during damage taken animation
	if !enemyActivation or is_waiting or health.is_defeated or is_damaged:
		return
	
	# This should be whatever the player instance is
	if (get_node("/root/Run/CurrentView/Main/player") != null):
		player = get_node("/root/Run/CurrentView/Main/player")
	
	var x_distance = global_position.x - player.global_position.x
	var y_distance = global_position.y - player.global_position.y
	
	# Face toward player
	sprite.flip_h = x_distance > 0
	
	# Take dot if corrupted by plague
	if take_dot:
		damage_over_time()
	
	handle_process(delta)

func _on_health_component_health_change(character_newHealth: Variant) -> void:
	is_damaged = true
	health_ui.scale.x = float(character_newHealth) / max_health
	sprite.play("hurt")
	await sprite.animation_finished
	is_damaged = false
	
func _on_health_component_destroyed() -> void:
	is_defeated.emit()
	bar_ui.visible = false
	sprite.play("death")
	death_explosion.emitting = true;
	await sprite.animation_finished
	spawn_coin()
	queue_free()

func spawn_coin() -> void:
	var coin_scene = preload("res://Gold_Component/Coin Component.tscn")  # Adjust path to your Coin scene
	var coin_instance = coin_scene.instantiate()
	get_parent().add_child(coin_instance)
	coin_instance.global_position = global_position  # Place coin at enemy's position

func _on_enemy_activated() -> void:
	health.MAX_HEALTH = max_health
	health.current_health = max_health
	break_bar.MAX_BREAK_BAR = max_break_bar
	break_bar.current_break_bar = max_break_bar
	global_position = get_parent().global_position
	bar_ui.visible = true
	enemyActivation = true

func _on_enemy_deactivated() -> void:
	enemyActivation = false
	global_position = get_parent().global_position

func pause_enemy():
	is_waiting = true  # Stop movement
	await get_tree().create_timer(wait_time, false).timeout  # Wait for the set time
	is_waiting = false  # Resume movement

func _on_break_component_broken() -> void:
	death_explosion.emitting = true;
	pause_enemy()

func _on_break_component_break_damage(amount: Variant, type: Variant) -> void:
	if type == "plague_festering_boils":
		break_damage_multiplier /= break_factor
		take_dot = true
	if type == "plague_rattlejoint_ache":
		speed *= break_factor
		dash_speed *= break_factor
		take_dot = true
	if type == "plague_withering_cough":
		damage *= break_factor
		knockback *= break_factor
		take_dot = true
	health.damage_taken(amount * break_damage_multiplier)

func _on_break_component_break_change(newBreak: Variant) -> void:
	break_ui.scale.x = float(newBreak) / max_break_bar
