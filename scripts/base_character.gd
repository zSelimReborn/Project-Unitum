class_name BaseCharacter

extends CharacterBody2D

# On Ready
@onready var sprite = $Sprite

# Properties
@export var walk_speed : float
@export var jump_velocity : float

@export var max_health : float
@onready var health = max_health

@export var base_damage : float
@onready var damage = base_damage

# Variables
var is_alive : bool = true
var damage_multiplier : float = 1

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Movement functions
func add_movement(direction : float):
	direction = clamp(direction, -1, 1)
	velocity.x = direction * walk_speed
	
func jump():
	velocity.y = jump_velocity
	
func process_movement_input():
	pass
	
func flip_sprite(left: bool):
	sprite.flip_h = left
	
func handle_sprite(direction: float):
	if direction == 0:
		return

	var is_left = direction < 0
	flip_sprite(is_left)

func _physics_process(delta):
	process_movement_input()
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	move_and_slide()

# Health management
func die():
	is_alive = false
	print("DIE")
	
func take_damage(amount : float):
	if not is_alive:
		return
	health = clamp(health - amount, 0, max_health)
	if health <= 0:
		die()
	print("health: ", health)
