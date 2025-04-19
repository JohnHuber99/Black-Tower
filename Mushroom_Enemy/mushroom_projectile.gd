extends Area2D

@export var speed: float = 300.0
@export var damage: int = 10
var direction := Vector2.ZERO

func _ready():
	connect("body_entered", _on_body_entered)

func _physics_process(delta: float) -> void:
	if direction != Vector2.ZERO:
		position += direction.normalized() * speed * delta

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		if body.iframe_timer <= 0:
			body.health.damage_taken(damage)
			queue_free()
	elif body.is_in_group("wall"):  
		queue_free()
