class_name Player

extends BaseCharacter

# On Ready
@onready var t_right_marker = $TRightMarker
@onready var t_left_marker = $TLeftMarker
@onready var b_right_marker = $BRightMarker
@onready var b_left_marker = $BLeftMarker

#Properties
@export var fire_ball_class : PackedScene
@export var water_ball_class : PackedScene
@export var earth_ball_class : PackedScene
@export var air_ball_class : PackedScene

#Variables
var current_element : Types.Elements = Types.Elements.FIRE
var state : Types.PlayerState = Types.PlayerState.Character
var element_abilities = {}
var markers = {}
var marker = null
var current_interactable : BaseInteractable = null

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
		
func fire():
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
	setup_markers()
	select_marker(false)
	
func setup_projectiles():
	element_abilities = {
		Types.Elements.FIRE: fire_ball_class,
		Types.Elements.WATER: water_ball_class,
		Types.Elements.EARTH: earth_ball_class,
		Types.Elements.AIR: air_ball_class
	}
	
func setup_markers():
	markers = {
		Types.PlayerState.Character: [t_right_marker, t_left_marker],
		Types.PlayerState.Shadow: [b_right_marker, b_left_marker]
	}
	
func select_marker(left: bool):
	var marker_index = int(left)
	marker = markers[state][marker_index]
