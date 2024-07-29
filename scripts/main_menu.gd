class_name MainMenu

extends Control

# Properties
@export var first_level : PackedScene

# On Ready
@onready var main_container = $Panel/MainContainer
@onready var credits_container = $Panel/CreditsContainer

func _on_new_game_button_pressed():
	if not first_level:
		printerr("unable to start new game, no level")
		return
	
	SceneManager.goto_scene(first_level.resource_path)


func _on_exit_button_pressed():
	get_tree().quit()


func _on_credits_button_pressed():
	main_container.hide()
	credits_container.show()


func _on_back_button_pressed():
	main_container.show()
	credits_container.hide()
