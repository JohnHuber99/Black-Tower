extends Node

const RUN_SCENE = preload("res://Run/run.tscn")
const DUNGEON_SCENE = preload("res://dungeon.tscn")
const OVERWORLD_MAP_SCENE = preload("res://OverWorld Map/Overworld_Map_Scenes/overworld_map.tscn")

func _ready() -> void:
	get_tree().paused = false
	MusicManager.play_music("main_menu")

func _on_play_game_pressed() -> void:
	get_tree().change_scene_to_packed(RUN_SCENE)
	
func _on_exit_pressed() -> void:
	get_tree().quit()
