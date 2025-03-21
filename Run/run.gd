class_name Run
extends Node

const DUNGEON_SCENE = preload("res://main.tscn")

@onready var current_view: Node = $CurrentView
@onready var overworld_map: OverworldMap = $OverworldMap
@onready var run_startup = preload("res://Run/run_startup_resource.tres")

func _ready() -> void:	
	if not run_startup:
		return
		
	match run_startup.type:
		RunStartUp.Type.NEW_RUN:
			_start_run()
		RunStartUp.Type.CONTINUED_RUN:
			print("TODO: Load previous run")
		
func _start_run() -> void:
	_set_up_event_connections()
	overworld_map.generate_new_map()
	overworld_map.unlock_floor(0)
	
func _change_view(scene: PackedScene) -> void:
	if current_view.get_child_count() > 0:
		current_view.get_child(0).queue_free()
	
	get_tree().paused = false
	var new_view := scene.instantiate()
	current_view.add_child(new_view)
	overworld_map.hide_map()

func _show_map() -> void:
	print("Show Map")
	if current_view.get_child_count() > 0:
		current_view.get_child(0).queue_free()
		
	overworld_map.show_map()
	overworld_map.unlock_next_rooms()
	
func _set_up_event_connections() -> void:
	Events.overworld_map_exited.connect(_on_overworld_map_exited)
	Events.dungeon_cleared.connect(_show_map)

func _on_overworld_map_exited(room: Room) -> void:
	match room.type:
		Room.Type.MONSTER:
			_change_view(DUNGEON_SCENE)
		Room.Type.ELITE_MONSTER:
			_change_view(DUNGEON_SCENE)
		Room.Type.TREASURE:
			_change_view(DUNGEON_SCENE)
		Room.Type.CAMPFIRE:
			_change_view(DUNGEON_SCENE)
		Room.Type.SHOP:
			_change_view(DUNGEON_SCENE)
		Room.Type.BOSS:
			_change_view(DUNGEON_SCENE)
