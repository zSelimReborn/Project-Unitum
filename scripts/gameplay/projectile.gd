class_name Projectile

extends Area2D

#On Ready
@onready var sprite = $Sprite2D

# Properties
@export var speed : float = 750

# Variables
var damage : float = 0
var instigator = null

func set_sprite_texture(texture):
	sprite.set_texture(texture)

func _physics_process(delta):
	var x_offset = transform.x * speed * delta
	position += x_offset

func _on_body_entered(body):
	if body == instigator:
		return
	queue_free()
