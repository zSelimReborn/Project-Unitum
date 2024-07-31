class_name MainMenu

extends Control

# Properties
@export var first_level : String
var temp = preload("res://scenes/levels/earth_level.tscn")

# On Ready
@onready var main_container = $Panel/MainContainer
@onready var credits_container = $Panel/CreditsContainer
@onready var audio = $Audio

func _on_new_game_button_pressed():
	if not first_level:
		printerr("unable to start new game, no level")
		return
	
	play_button_sound()	
	SceneManager.goto_scene(first_level)


func _on_exit_button_pressed():
	play_button_sound()
	get_tree().quit()

func _on_credits_button_pressed():
	play_button_sound()	
	main_container.hide()
	credits_container.show()

func _on_back_button_pressed():
	play_button_sound()	
	main_container.show()
	credits_container.hide()

func play_button_sound():
	if not audio:
		return
	audio.play()
