extends Node2D

@onready var menu = $Menu

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = false
	menu.visible = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = !get_tree().paused
		menu.visible = !menu.visible

func _on_resume_pressed() -> void:
	get_tree().paused = false
	menu.visible = false

func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Main_Menu/Main_Menu.tscn")
