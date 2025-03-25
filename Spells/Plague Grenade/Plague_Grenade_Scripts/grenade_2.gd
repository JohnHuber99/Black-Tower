extends Path2D

@export var speed = 500
@export var targetPosition: Vector2

@onready var path_follow_2d = $PathFollow2D
@onready var grenade_sprite = $PathFollow2D/Area2D/Sprite2D
@onready var explosion_sprite = $AnimatedSprite2D

func _ready():
	curve.clear_points()
	curve.add_point(global_position)
	curve.add_point((global_position + targetPosition) / 2 + Vector2(0, -abs(targetPosition.x) / 3))
	curve.add_point(targetPosition)
	
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
	await explosion_sprite.animation_finished
	queue_free()

	
