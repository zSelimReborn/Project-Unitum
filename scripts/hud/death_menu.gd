class_name DeathMenu

extends Control

# Events
signal restart_pressed()
signal back_pressed()
signal exit_pressed()


func _on_restart_button_pressed():
	restart_pressed.emit()

func _on_back_button_pressed():
	back_pressed.emit()

func _on_exit_button_pressed():
	exit_pressed.emit()
