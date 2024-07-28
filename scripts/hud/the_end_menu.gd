class_name TheEndMenu

extends Control

# Properties
@export var initial_level : PackedScene
@export var human_description : String
@export var shadow_description : String
@export var good_description : String
@export var pacifist_description : String

# On Ready
@onready var end_description = $Background/Container/EndDescription

# Variables
var initial_level_path = null

func setup_initial_level_path():
	if not initial_level:
		printerr("end menu, initial level empty, fall back to main menu")
		initial_level_path = "res://scenes/main_menu_level.tscn"
	else:
		initial_level_path = initial_level.resource_path
		
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	setup_initial_level_path()
	setup_end_description()
	
func setup_end_description():
	if not end_description:
		printerr("end menu, cannot set end description")
		return
	var text = "";
	match PlayerStorage.ending:
		Types.Ending.Human:
			text = human_description
			pass
		Types.Ending.Shadow:
			text = shadow_description
			pass
		Types.Ending.Good:
			text = good_description
			pass
		Types.Ending.Pacifist:
			text = pacifist_description
	end_description.text = text

func _on_restart_button_pressed():
	PlayerStorage.reset()
	SceneManager.goto_scene(initial_level_path)

func _on_exit_button_pressed():
	get_tree().quit()
