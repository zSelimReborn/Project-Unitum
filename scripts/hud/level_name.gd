class_name LevelName

extends Control

#On Ready
@onready var name_label = $HBoxContainer/Name
@onready var label = $HBoxContainer/Label


func set_level_name(new_name: String):
	if not new_name:
		name_label.text = ""
		label.visible = false
		return
	name_label.text = new_name
	label.visible = true
