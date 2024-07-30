class_name PauseMenu

extends Control

# Variables
var current_player: Player = null

# On Ready
@onready var audio = $Audio

# Events
signal continue_pressed()
signal exit_pressed()

func setup_player(player: Player):
	if not player:
		printerr("unable to set pause menu, no player")
		return
	current_player = player

func _on_continue_button_pressed():
	play_button_sound()
	continue_pressed.emit()

func _on_exit_button_pressed():
	play_button_sound()
	exit_pressed.emit()

func play_button_sound():
	if not audio:
		return
	audio.play()
