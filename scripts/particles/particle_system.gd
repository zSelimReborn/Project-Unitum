class_name ParticleSystem

extends GPUParticles2D

func _ready():
	await get_tree().create_timer(100).timeout
	queue_free()
