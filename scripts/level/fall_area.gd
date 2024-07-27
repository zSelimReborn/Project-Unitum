class_name FallArea

extends Area2D

func _ready():
	pass # Replace with function body.


func _on_body_entered(body):
	var player = body as Player
	if not player:
		return
	player.restore_after_fall()
