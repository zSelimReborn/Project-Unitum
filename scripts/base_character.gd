class_name BaseCharacter

extends CharacterBody2D

# On Ready
@onready var sprite = $AnimatedSprite2D

# Properties
@export var walk_speed : float
@export var jump_velocity : float
@export var apply_gravity : bool = true
@export var idle_animation : String = "idle"
@export var walk_animation : String = ""

@export var max_health : float
@export var hit_flash_duration : float = 0.2
@onready var health = max_health

@export var base_damage_multiplier : float = 0.25
var base_damage = 100
@onready var damage_multiplier = base_damage_multiplier

# Variables
var is_alive : bool = true
var current_impulse = Vector2()

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Movement functions
func add_movement(direction : float):
	if not current_impulse.is_zero_approx():
		return
	direction = clamp(direction, -1, 1)
	velocity.x = direction * walk_speed
	
func add_impulse(impulse: Vector2):
	current_impulse = impulse
	velocity = current_impulse
		
func jump():
	velocity.y = jump_velocity
	
func flip_sprite(left: bool):
	sprite.flip_h = left
	
func handle_sprite(direction: float):
	if direction == 0:
		return

	var is_left = direction < 0
	flip_sprite(is_left)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor() and apply_gravity:
		velocity.y += gravity * delta
	
	move_and_slide()
	
	# Consume impulse
	if not current_impulse.is_zero_approx():
		velocity.x += -current_impulse.x * delta
		if (abs(velocity.x) < Types.DISTANCE_INTERNAL_EPSILON or is_on_wall()):
			current_impulse = Vector2()
			velocity.x = 0
	
	process_animation(delta)
	
func process_animation(_delta):
	if is_on_floor():
		if velocity.length_squared() > 0 and not walk_animation.is_empty():
			sprite.play(walk_animation)
			return

	sprite.play(idle_animation)

# Health management
func die():
	is_alive = false
	
func heal(amount: float):
	if not is_alive:
		return
	amount = abs(amount)
	health = clamp(health + amount, 0, max_health)
	print("health: ", health)
	
func can_take_damage(_instigator):
	return true
	
func take_damage(amount: float):
	if not is_alive:
		return
	health = clamp(health - amount, 0, max_health)
	if health <= 0:
		die()
		return
	update_shader_flag("active", true)
	await get_tree().create_timer(hit_flash_duration).timeout
	update_shader_flag("active", false)	
	
func get_damage():
	return base_damage * damage_multiplier
	
func update_shader_flag(shader: String, active: bool):
	if not sprite or not sprite.material:
		printerr("unable to update shader flag, no: ", shader)
		return
	sprite.material.set_shader_parameter(shader, active)
