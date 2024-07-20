class_name BaseInteractable

extends Area2D

# Properties

# Interact on player enter
@export var instant_interact: bool = false

func interact(player: Player):
	pass

func on_overlap_start(player: Player):
	if player == null:
		return
	player.current_interactable = self

func on_overlap_leave(player: Player):
	if player == null:
		return
	player.current_interactable = null

func _on_body_entered(body):
	var player := body as Player
	if player == null:
		return
	if instant_interact:
		interact(player)
	else:
		on_overlap_start(player)


func _on_body_exited(body):
	var player := body as Player
	if player == null:
		return
	if not instant_interact:
		on_overlap_leave(player)
