class_name Player

extends BaseCharacter

# On Ready
@onready var top_marker = $TopAnchor/TopMarker
@onready var bottom_marker = $BottomAnchor/BottomMarker
@onready var top_anchor = $TopAnchor
@onready var bottom_anchor = $BottomAnchor
@onready var fire_rate_timer = $FireRateTimer

#Properties
@export var fire_ball_class : PackedScene
@export var water_ball_class : PackedScene
@export var earth_ball_class : PackedScene
@export var air_ball_class : PackedScene
@export var fire_rate : float = 0.5

#Variables
var current_element : Types.Elements = Types.Elements.FIRE
var state : Types.PlayerState = Types.PlayerState.Character
var element_abilities = {}
var current_interactable : BaseInteractable = null
var marker = null
var can_shoot = true

var element_input_mapping = {
	KEY_1: Types.Elements.FIRE,
	KEY_2: Types.Elements.WATER,
	KEY_3: Types.Elements.EARTH,
	KEY_4: Types.Elements.AIR
}

func process_movement_input():
	var movement_direction = Input.get_axis("move_left", "move_right")
	add_movement(movement_direction)
	handle_sprite(movement_direction)

	if Input.is_action_just_pressed("jump") and is_on_floor():
		jump()

func _input(event):
	if event.is_action_pressed("fire"):
		fire()
	if event.is_action_pressed("change_element"):
		change_element(event.keycode)
	if event.is_action_pressed("interact"):
		interact()
	if event.is_action_pressed("take"):
		take_damage(10)
		
func fire():
	if not can_shoot:
		printerr("unable to fire, cooldown")
		return
	if marker == null:
		printerr("unable to fire, no marker")
		return
	var projectile_class = element_abilities[current_element]
	if not projectile_class:
		printerr("unable to fire, no projectile class")
		return
	var projectile = projectile_class.instantiate()
	owner.add_child(projectile)
	projectile.instigator = self
	projectile.transform = marker.global_transform
	sprite.play("attack")
	can_shoot = false
	fire_rate_timer.start()
		
func change_element(keycode):
	if not element_input_mapping.has(keycode):
		printerr("unable to change element")
		return
	current_element = element_input_mapping[keycode]

func flip_sprite(left: bool):
	super(left)
	select_marker(left)
		
func interact():
	if current_interactable == null:
		printerr("no interaction available")
		return
	current_interactable.interact(self)
	
func flip_state(new_transform: Transform2D):
	if is_shadow():
		state = Types.PlayerState.Character
	else:
		state = Types.PlayerState.Shadow
	transform = new_transform
	on_flip_state()
	
func is_shadow():
	return state == Types.PlayerState.Shadow
	
func on_flip_state():
	gravity = -gravity
	sprite.flip_v = not sprite.flip_v
	jump_velocity = -jump_velocity
	up_direction.y = -up_direction.y
	select_marker(sprite.flip_h)
	if is_shadow():
		sprite.modulate.a = 0.5
	else:
		sprite.modulate.a = 1

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	setup_projectiles()
	select_marker(false)
	setup_fire_rate()
	
func setup_projectiles():
	element_abilities = {
		Types.Elements.FIRE: fire_ball_class,
		Types.Elements.WATER: water_ball_class,
		Types.Elements.EARTH: earth_ball_class,
		Types.Elements.AIR: air_ball_class
	}
	
func setup_fire_rate():
	fire_rate_timer.one_shot = true
	fire_rate_timer.wait_time = fire_rate
	fire_rate_timer.stop()
	
func _on_fire_rate_timeout():
	can_shoot = true
	
func select_marker(left: bool):
	var direction_rotation = 180 if left else 0
	var selected_anchor = bottom_anchor if is_shadow() else top_anchor
	selected_anchor.rotation_degrees = direction_rotation
	marker = bottom_marker if is_shadow() else top_marker

