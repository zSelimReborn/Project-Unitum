class_name MainMenu

extends Control

@export var first_level : PackedScene

func _on_new_game_button_pressed():
	if not first_level:
		printerr("unable to start new game, no level")
		return
	
	SceneManager.goto_scene(first_level.resource_path)


func _on_exit_button_pressed():
	get_tree().quit()
