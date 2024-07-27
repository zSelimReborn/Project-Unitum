class_name DialogueBox

extends Control

# On Ready
@onready var dialogue_label = $Container/Box/Dialogue

func set_dialogue(text: String):
	if not dialogue_label:
		printerr("unable to load dialogue label")
		return
	dialogue_label.text = text
