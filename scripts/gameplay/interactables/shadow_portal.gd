class_name ShadowPortal

extends BaseInteractable

@export var spawn_point: Node2D
@export var sound : AudioStream

@onready var audio = $Audio

func interact(player: Player):
	if spawn_point == null:
		printerr("unable to use shadow portal, empty spawn point")
		return false
	if player == null:
		printerr("unable to use shadow portal, empty player")
		return false
	player.flip_state(spawn_point.transform)
	play_audio()
	return true

func play_audio():
	if not audio or not sound:
		return
	if audio.is_playing():
		return
	audio.stream = sound
	audio.play()
