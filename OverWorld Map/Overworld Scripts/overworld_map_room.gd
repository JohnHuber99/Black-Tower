class_name MapRoom
extends Area2D

signal selected(room: Room)

const ICONS := {
	Room.Type.NOT_ASSIGNED: [null, Vector2.ONE],
	Room.Type.MONSTER: [preload("res://OverWorld Map/Overwrold Tilemaps/Overworld Map Icons/icon_sword.png"), Vector2.ONE],
	Room.Type.ELITE_MONSTER: [preload("res://OverWorld Map/Overwrold Tilemaps/Overworld Map Icons/icon_beetle.png"), Vector2.ONE],
	Room.Type.SHOP: [preload("res://OverWorld Map/Overwrold Tilemaps/Overworld Map Icons/icon_bag.png"), Vector2(0.6, 0.6)],
	Room.Type.CAMPFIRE: [preload("res://OverWorld Map/Overwrold Tilemaps/Overworld Map Icons/icon_heart.png"), Vector2(0.6, 0.6)],
	Room.Type.TREASURE: [preload("res://OverWorld Map/Overwrold Tilemaps/Overworld Map Icons/icon_chest.png"), Vector2.ONE],
	Room.Type.BOSS: [preload("res://OverWorld Map/Overwrold Tilemaps/Overworld Map Icons/icon_skull.png"), Vector2.ONE]
}

@onready var sprite_2d: Sprite2D = get_node("Visuals/Sprite2D")
@onready var line_2d: Line2D = get_node("Visuals/Line2D")
@onready var animation_player: AnimationPlayer = get_node("AnimationPlayer")

var available := false : set = set_available
var room: Room : set = set_room

func set_available(new_value: bool) -> void:
	available = new_value
	
	if available:
		animation_player.play("Overworld_Icon_Highlight")
	elif not room.selected:
		animation_player.play("RESET")

func set_room(new_value: Room) -> void:
	room = new_value
	position = room.position
	line_2d.rotation_degrees = randi_range(0, 360)
	
	var icon_data = ICONS.get(room.type, [null, Vector2.ONE])
	sprite_2d.texture = icon_data[0]
	sprite_2d.scale = icon_data[1]

func show_selected() -> void:
	line_2d.modulate = Color.WHITE

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not available or not event.is_action_pressed("left_mouse"):
		return
	
	room.selected = true
	animation_player.play("select_overworld_icon")

# Called by the AnimationPlayer when the
# "select" animation finishes.
func _on_map_room_selected() -> void:
	print("Emitting Map Room Selected")
	selected.emit(room)
