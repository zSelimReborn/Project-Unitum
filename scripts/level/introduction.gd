class_name Introduction

extends BaseInteractable

# On Ready
@onready var dialogue = "res://assets/dialogues/introduction.txt"

func interact(player: Player):
	if not player:
		printerr("cannot start introduction, no player")
		return false
	if not dialogue:
		printerr("cannot start introduction, no dialogue")
		return false
	if not player.init_dialogue(dialogue, "introduction"):
		printerr("introduction initialization failed")
		return false
	player.start_dialogue()
	return true
