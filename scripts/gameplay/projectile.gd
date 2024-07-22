class_name Projectile

extends Area2D

#On Ready
@onready var timer = $Timer
@onready var sprite = $AnimSprite

# Properties
@export var speed : float = 750

# Variables
var damage : float = 0
var instigator = null

func _ready():
	timer.start()

func _physics_process(delta):
	var x_offset = transform.x * speed * delta
	position += x_offset

func _on_body_entered(body):
	if body == instigator:
		return
	queue_free()

func _on_timer_timeout():
	queue_free()

func _on_anim_sprite_animation_looped():
	if sprite.animation == "default":
		sprite.play("loop")
