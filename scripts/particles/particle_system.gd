class_name ParticleSystem

extends GPUParticles2D

func _ready():
	await get_tree().create_timer(1000).timeout
	queue_free()
