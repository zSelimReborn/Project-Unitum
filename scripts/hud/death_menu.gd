class_name DeathMenu

extends Control

@onready var audio = $Audio

# Events
signal restart_pressed()
signal back_pressed()
signal exit_pressed()


func _on_restart_button_pressed():
	play_button_sound()
	restart_pressed.emit()

func _on_back_button_pressed():
	play_button_sound()	
	back_pressed.emit()

func _on_exit_button_pressed():
	play_button_sound()	
	exit_pressed.emit()
	
func play_button_sound():
	if not audio:
		return
	audio.play()
