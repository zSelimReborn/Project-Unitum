class_name InteractText

extends Control

@onready var text = $Container/Text
@onready var image = $Container/Image

func _ready():
	image.visible = false

func setup_player(player: Player):
	if not player:
		printerr("unable to set interact text, no player")
		return
	player.on_interactable.connect(on_interactable)
	
func on_interactable(interactable: BaseInteractable):
	image.visible = false	
	if not text:
		printerr("unable to set interact text, no label")
		return
	var new_text = ""
	if interactable and not interactable.instant_interact and interactable.is_interactable:
		new_text = interactable.interaction_text
		image.visible = true		
	text.text = new_text
