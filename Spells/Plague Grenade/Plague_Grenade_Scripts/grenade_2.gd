extends Path2D

@export var speed = 600
@export var targetPosition: Vector2
@export var damage = 50

@onready var path_follow_2d = $PathFollow2D
@onready var grenade_sprite = $PathFollow2D/Area2D/Sprite2D
@onready var explosion_sprite = $AnimatedSprite2D
@onready var area_2d = $PathFollow2D/Area2D

var damaged_enemies = []

func _ready():
	curve.clear_points()
	curve.add_point(global_position)
	var distance = targetPosition.length()
	var arc_height = -min(distance / 4, 100)
	curve.add_point((global_position + targetPosition) / 2 + Vector2(0, arc_height))
	curve.add_point(global_position + targetPosition)
	
	path_follow_2d.progress = 0
	path_follow_2d.loop = false
	explosion_sprite.visible = false
	grenade_sprite.visible = true
	
func _process(delta):
	if not targetPosition: return
	
	path_follow_2d.progress += speed * delta
	
	if path_follow_2d.progress_ratio >= 0.98:
		explode()

func explode():
	var explosion_position = path_follow_2d.global_position
	grenade_sprite.visible = false
	explosion_sprite.global_position = explosion_position
	explosion_sprite.visible = true
	explosion_sprite.play("explosion")
	
	for body in area_2d.get_overlapping_bodies():
		if body is Enemy and body not in damaged_enemies:
			body.health.damage_taken(damage)
			damaged_enemies.append(body) 
	
	await explosion_sprite.animation_finished
	queue_free()

	
