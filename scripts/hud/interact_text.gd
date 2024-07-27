class_name InteractText

extends Control

@onready var text = $HBoxContainer/Text

func setup_player(player: Player):
	if not player:
		printerr("unable to set interact text, no player")
		return
	player.on_interactable.connect(on_interactable)
	
func on_interactable(interactable: BaseInteractable):
	if not text:
		printerr("unable to set interact text, no label")
		return
	var new_text = ""
	if interactable and not interactable.instant_interact:
		new_text = interactable.interaction_text
	text.text = new_text
