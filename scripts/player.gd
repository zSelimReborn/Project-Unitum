class_name Player

extends BaseCharacter

# On Ready
@onready var top_marker = $TopAnchor/TopMarker
@onready var bottom_marker = $BottomAnchor/BottomMarker
@onready var top_anchor = $TopAnchor
@onready var bottom_anchor = $BottomAnchor
@onready var fire_rate_timer = $FireRateTimer
@onready var relic_component = $RelicComponent

#Properties
@export var fire_ball_class : PackedScene
@export var water_ball_class : PackedScene
@export var earth_ball_class : PackedScene
@export var air_ball_class : PackedScene
@export var fire_rate : float = 0.5
@export var main_group : String = "player"
@export var greyscale_rect : ColorRect

#Variables
var current_element : Types.Elements = Types.Elements.FIRE
var state : Types.PlayerState = Types.PlayerState.Character
var element_abilities = {}
var current_interactable : BaseInteractable = null
var marker = null
var can_shoot = true
var in_game = true
var in_dialogue = false

# Events
signal on_change_state(old_state, new_state)
signal on_interactable(interactable: BaseInteractable)
signal on_change_element(old_element, current_element)
signal on_pause_menu_requested()
signal on_interaction_hint_requested(interactable: BaseInteractable)
signal jump_dialogue_requested()
signal next_dialogue_requested()

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

	if in_dialogue and event.is_action_pressed("jump_dialogue"):
		handle_jump_dialogue()
	elif not in_dialogue and event.is_action_pressed("pause"):
		switch_pause_menu()
	elif not in_dialogue and in_game:
		process_movement_input()
		if event.is_action_pressed("fire"):
			fire()
		if event.is_action_pressed("change_element"):
			change_element(event.keycode)
		if event.is_action_pressed("interact"):
			interact()

		
func fire():
	if not can_shoot:
		printerr("unable to fire, cooldown")
		return
	if marker == null:
		printerr("unable to fire, no marker")
		return
	var projectile = spawn_projectile()
	if not projectile:
		printerr("unable to fire, no projectile class")
		return		
	sprite.play("attack")
	can_shoot = false
	fire_rate_timer.start()
	
func spawn_projectile():
	var projectile_class = element_abilities[current_element]	
	return Common.spawn_projectile(owner, projectile_class, self, main_group, get_damage(), current_element, marker.global_transform)
		
func change_element(keycode):
	if not element_input_mapping.has(keycode):
		printerr("unable to change element")
		return
	var old_element = current_element
	current_element = element_input_mapping[keycode]
	on_change_element.emit(old_element, current_element)

func flip_sprite(left: bool):
	super(left)
	select_marker(left)
		
func interact():
	if current_interactable == null:
		printerr("no interaction available")
		return
	if not current_interactable.interact(self):
		on_interaction_hint_requested.emit(current_interactable)
	
func flip_state(new_transform: Transform2D):
	var old_state = state
	if is_shadow():
		state = Types.PlayerState.Character
	else:
		state = Types.PlayerState.Shadow
	transform = new_transform
	on_change_state.emit(old_state, state)
	on_flip_state()
	
func is_shadow():
	return state == Types.PlayerState.Shadow
	
func on_flip_state():
	gravity = -gravity
	sprite.flip_v = not sprite.flip_v
	jump_velocity = -jump_velocity
	up_direction.y = -up_direction.y
	select_marker(sprite.flip_h)
	update_shader_flag("shadow", is_shadow())
	update_greyscale()

func _ready():
	add_to_group(main_group)
	switch_gameplay()
	setup_projectiles()
	select_marker(false)
	setup_fire_rate()
	setup_relic_event()
	
func setup_projectiles():
	element_abilities = {
		Types.Elements.FIRE: fire_ball_class,
		Types.Elements.WATER: water_ball_class,
		Types.Elements.EARTH: earth_ball_class,
		Types.Elements.AIR: air_ball_class
	}
	
func set_interactable(interactable: BaseInteractable):
	current_interactable = interactable
	on_interactable.emit(interactable)
	
func setup_fire_rate():
	fire_rate_timer.one_shot = true
	fire_rate_timer.wait_time = fire_rate
	fire_rate_timer.stop()
	
func setup_relic_event():
	if not relic_component:
		return
	relic_component.new_relic_added.connect(on_new_relic)
	
func on_new_relic(type: Types.PlayerState, amount: int):
	damage_multiplier += relic_component.relic_multiplier
	
func _on_fire_rate_timeout():
	can_shoot = true
	
func select_marker(left: bool):
	var direction_rotation = 180 if left else 0
	var selected_anchor = bottom_anchor if is_shadow() else top_anchor
	selected_anchor.rotation_degrees = direction_rotation
	marker = bottom_marker if is_shadow() else top_marker
	
func die():
	super()
	get_tree().reload_current_scene()

func update_greyscale():
	if not greyscale_rect:
		return
	greyscale_rect.material.set_shader_parameter("enabled", is_shadow())
	
func switch_pause_menu():
	if in_game:
		switch_ui(true, true)
	else:
		switch_gameplay()
	on_pause_menu_requested.emit()
	in_game = not in_game
	
func switch_dialogue():
	in_dialogue = not in_dialogue
	
func handle_jump_dialogue():
	# Handle here next dialogue
	jump_dialogue_requested.emit()
	
func switch_ui(show_cursor, pause_game):
	if show_cursor:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if pause_game:
		Engine.time_scale = 0
	else:
		Engine.time_scale = 1

func switch_gameplay():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	Engine.time_scale = 1
