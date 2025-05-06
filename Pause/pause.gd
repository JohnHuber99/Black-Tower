extends Node2D

@onready var menu = $Menu
@onready var resume_button = $Menu/Resume
@onready var death_label = $Menu/CanvasLayer/DeathLabel


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = false
	resume_button.visible = true
	death_label.visible = false
	menu.visible = false

func _process(delta: float) -> void:
	if !death_label.visible and Input.is_action_just_pressed("pause"):
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


func _on_ui_game_over() -> void:
	death_label.parse_bbcode("[center][color=red]You Died![/color]\nPress [color=yellow]'Restart'[/color] to try again[/center]")
	death_label.visible = true  # Show the message
	resume_button.visible = false
	get_tree().paused = !get_tree().paused
	menu.visible = !menu.visible
