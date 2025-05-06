extends Enemy

@export var projectile_scene: PackedScene
@export var shoot_cooldown: float = 2.0
@export var hunker_cooldown: float = 1.0
@export var defense_duration: float = 1.5
@export var damage_resistance: float = 0.5  # 50% damage reduction while hunkered

var can_shoot := true
var can_hunker := true
var is_hunkering = false

func handle_physics_process(delta: float) -> void:
	if sprite.animation == "default":
		move_toward_player(delta)

func handle_process(delta: float) -> void:
	if sprite.animation == "default":
		if global_position.distance_to(player.global_position) > attack_proximity and can_shoot and !is_hunkering:
			shoot()
		elif global_position.distance_to(player.global_position) < attack_proximity and can_hunker:
			hunker()
	else:
		if !sprite.is_playing() and !is_hunkering:
			sprite.play("default")

func move_toward_player(delta: float) -> void:
	last_direction = (player.global_position - global_position).normalized()
	var motion = -1 * last_direction * speed * delta
	collision = move_and_collide(motion)

func hunker() -> void:
	is_hunkering = true
	sprite.play("hunker")
	await sprite.animation_finished

	# Enter defense mode
	health.damage_resistance = damage_resistance
	break_bar.damage_resistance = damage_resistance
	await get_tree().create_timer(defense_duration, false).timeout

	# Exit defense mode
	health.damage_resistance = 1.0
	is_hunkering = false
	
	can_hunker = false
	await get_tree().create_timer(hunker_cooldown, false).timeout
	can_hunker = true

func shoot():
	can_shoot = false
	# Shoot projectile
	sprite.play("attack_1")
	await sprite.animation_finished
	shoot_projectile()
	sprite.play("attack_2")
	await sprite.animation_finished

	# Cooldown before next attack
	await get_tree().create_timer(shoot_cooldown, false).timeout
	can_shoot = true

func shoot_projectile():
	if not projectile_scene:
		return
	var projectile = projectile_scene.instantiate()
	get_parent().add_child(projectile)
	projectile.global_position = global_position
	projectile.look_at(player.global_position)
	projectile.direction = (player.global_position - global_position).normalized()
