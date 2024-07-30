class_name Projectile

extends Area2D

#On Ready
@onready var timer = $Timer
@onready var sprite = $AnimSprite
@onready var audio = $Audio

# Properties
@export var speed : float = 750
@export var loop_animation : bool = false
@export var particle : PackedScene
@export var shoot_sound : AudioStream
@export var explosion_sound : AudioStream

# Variables
var damage : float = 0
var instigator = null
var instigator_group = null
var element : Types.Elements

func _ready():
	add_to_group("projectile")
	timer.start()
	play_audio(shoot_sound)

func _physics_process(delta):
	var x_offset = transform.x * speed * delta
	position += x_offset

func _on_body_entered(body):
	if body == instigator:
		return
	if body.is_in_group(instigator_group):
		return
	
	var character = body as BaseCharacter
	var puzzle = body as PuzzlePiece
	if character:
		if not character.can_take_damage(self):
			return
		character.take_damage(damage)
		if not character.is_alive:
			increment_instigator_kill_count()
	elif puzzle:
		if not puzzle.try_solve_piece(self):
			return
	spawn_particle()
	deferred_audio(explosion_sound)
	queue_free()
	
func _on_timer_timeout():
	queue_free()

func _on_anim_sprite_animation_looped():
	if not loop_animation:
		return
	if sprite.animation == "default":
		sprite.play("loop")
		
func increment_instigator_kill_count():
	var character = instigator as BaseCharacter
	if character:
		character.new_kill()

func spawn_particle():
	if not particle:
		return
	var p = particle.instantiate()
	p.emitting = true
	p.transform = transform
	get_tree().current_scene.add_child(p)

func deferred_audio(track):
	AudioManager.play_sound(track, transform, 500)
	return	

func play_audio(track):
	audio.stream = track
	audio.play()
