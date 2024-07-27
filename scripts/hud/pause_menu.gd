class_name PauseMenu

extends Control

# Variables
var current_player: Player = null

# Events
signal continue_pressed()
signal exit_pressed()

func setup_player(player: Player):
	if not player:
		printerr("unable to set pause menu, no player")
		return
	current_player = player

func _on_continue_button_pressed():
	continue_pressed.emit()

func _on_exit_button_pressed():
	exit_pressed.emit()


func _on_button_pressed():
	print("Hllo")
