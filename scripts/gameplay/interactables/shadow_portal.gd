class_name ShadowPortal

extends BaseInteractable

@export var spawn_point: Node2D

func interact(player: Player):
	if spawn_point == null:
		printerr("unable to use shadow portal, empty spawn point")
		return
	if player == null:
		printerr("unable to use shadow portal, empty player")
		return
	player.flip_state(spawn_point.transform)
