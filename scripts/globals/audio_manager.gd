extends Node

func play_sound(track: AudioStream, location : Transform2D, attenuation : float):
	var stream = AudioStreamPlayer2D.new()
	stream.transform = location
	stream.max_distance = attenuation
	stream.stream = track
	get_tree().current_scene.add_child(stream)
	stream.play()
	await stream.finished
	stream.queue_free()
