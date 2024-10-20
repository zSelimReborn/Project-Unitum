class_name Player

extends BaseCharacter

const CAMERA_SHAKE_TRESHOLD = 2.0

# On Ready
@onready var top_marker = $TopAnchor/TopMarker
@onready var bottom_marker = $BottomAnchor/BottomMarker
@onready var top_anchor = $TopAnchor
@onready var bottom_anchor = $BottomAnchor
@onready var fire_rate_timer = $FireRateTimer
@onready var relic_component = $RelicComponent
@onready var camera = $Camera2D
@onready var audio = $Audio

#Properties
@export var fire_ball_class : PackedScene
@export var water_ball_class : PackedScene
@export var earth_ball_class : PackedScene
@export var air_ball_class : PackedScene
@export var fire_rate : float = 0.5
@export var main_group : String = "player"
@export var greyscale_rect : ColorRect
@export var shadow_anim_name : String = "shadow"
@export var shake_random_strength : float = 20.0

@export var audio_footstep_dx : AudioStream
@export var audio_footstep_sx : AudioStream
@export var audio_jump : AudioStream
@export var audio_landing : AudioStream

#Variables
var current_element : Types.Elements = Types.Elements.FIRE
var state : Types.PlayerState = Types.PlayerState.Character
var element_abilities = {}
var current_interactable : BaseInteractable = null
var marker = null
var can_shoot = true
var in_game = true
var in_dialogue = false
var last_position = null

var shake_duration : float = 5.0
var shake_strength : float = 0
var rng = RandomNumberGenerator.new()

var dialogue = []
var current_dialogue_index = 0
var current_dialogue_tag = ""

# Events
signal on_change_state(old_state, new_state)
signal on_interactable(interactable: BaseInteractable)
signal on_change_element(old_element, current_element)
signal on_relic_found(type, data)
signal on_pause_menu_requested()
signal on_death_menu_requested()
signal on_interaction_hint_requested(interactable: BaseInteractable)
signal jump_dialogue_requested(tag)
signal next_dialogue_requested(line: String)
signal camera_shake_ended()

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

func process_animation(_delta):
	if not is_alive:
		return
	if is_shadow():
		sprite.play(shadow_anim_name)
	elif not is_on_floor():
		sprite.play("jump")
	else:
		super(_delta)

func _physics_process(delta):
	if is_on_floor():
		last_position = transform
	process_camera_shake(delta)
	if in_dialogue:
		velocity.x = 0
	super(delta)
	process_footsteps()
	
func restore_after_fall():
	transform = last_position

func _input(event):
	if not is_alive:
		return
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
	update_greyscale()

func _ready():
	add_to_group(main_group)
	switch_gameplay()
	setup_projectiles()
	select_marker(false)
	setup_fire_rate()
	setup_relic_event()
	restore_state()	
	
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
	
func on_new_relic(type: Types.PlayerState, amount: int, relic_data):
	handle_new_relic(type, 1)
	switch_relic_menu(type, relic_data)
	PlayerStorage.relics = relic_component.get_relics()
	
func handle_new_relic(type: Types.PlayerState, amount: int):
	for i in amount:
		if type == Types.PlayerState.Character:
			damage_multiplier += relic_component.relic_attack_multiplier
		else:
			defense_multiplier -= relic_component.relic_defense_multiplier
	
func _on_fire_rate_timeout():
	can_shoot = true
	
func select_marker(left: bool):
	var direction_rotation = 180 if left else 0
	var selected_anchor = bottom_anchor if is_shadow() else top_anchor
	selected_anchor.rotation_degrees = direction_rotation
	marker = bottom_marker if is_shadow() else top_marker
	
func die():
	super()
	sprite.play("death")

func _on_animation_finished():
	if sprite.animation == "death":
		on_death_animation_finished()
	
func on_death_animation_finished():
	game_over()
	
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
	
func game_over():
	switch_ui(true, true)
	on_death_menu_requested.emit()
	in_game = false

func switch_relic_menu(type, data):
	if in_game:
		switch_ui(true, true)
	else:
		switch_gameplay()
	on_relic_found.emit(type, data)			
	in_game = not in_game
	
func switch_dialogue():
	in_dialogue = not in_dialogue
	
func handle_jump_dialogue():
	# Handle here next dialogue
	if dialogue.size() > 0 and current_dialogue_index + 1 < dialogue.size():
		current_dialogue_index += 1
		next_dialogue_requested.emit(dialogue[current_dialogue_index])
	else:
		jump_dialogue_requested.emit(current_dialogue_tag)
		reset_dialogue()
		
func reset_dialogue():
	dialogue = []
	current_dialogue_index = 0
	current_dialogue_tag = ""
	
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
	
func new_kill():
	super()
	PlayerStorage.kill_count = kill_count

func restore_state():
	kill_count = PlayerStorage.kill_count
	if not relic_component:
		return
	relic_component.restore_relics()
	var relics = relic_component.get_relics()
	for relic in relics:
		handle_new_relic(relic, relics[relic])
	print("kill count: ", kill_count)
	
func apply_camera_shake(duration):
	shake_duration = duration
	shake_strength = shake_random_strength
	
func process_camera_shake(delta):
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, shake_duration * delta)
		if camera:
			camera.offset = camera_shake_offset()
		if shake_strength < CAMERA_SHAKE_TRESHOLD:
			shake_strength = 0.0
			camera_shake_ended.emit()

func camera_shake_offset() -> Vector2:
	return Vector2(rng.randf_range(-shake_strength, shake_strength), rng.randf_range(-shake_strength, shake_strength))
	
func turn_in_shadow():
	state = Types.PlayerState.Shadow
	sprite.play(shadow_anim_name)

func init_dialogue(text_file_path, dialogue_tag):
	if not text_file_path or not FileAccess.file_exists(text_file_path):
		printerr("unable to initialize dialogue, failed to load ", text_file_path)
		return false
	var handler = FileAccess.open(text_file_path, FileAccess.READ)
	if not handler:
		printerr("unable to initialize dialogue, handler empty")
		return false
	dialogue = []
	current_dialogue_index = 0
	current_dialogue_tag = dialogue_tag
	while not handler.eof_reached():
		var line = handler.get_line()
		if line:
			dialogue.append(line)
	return true
	
func start_dialogue():
	if not dialogue or dialogue.size() <= 0:
		printerr("no dialogue initialized")
		return
	next_dialogue_requested.emit(dialogue[current_dialogue_index])

func process_footsteps():
	if not audio:
		return
	var track = audio.stream
	if track == audio_footstep_dx:
		track = audio_footstep_sx
	else:
		track = audio_footstep_dx
	if audio.is_playing():
		return
	if abs(velocity.x) > 0 and is_on_floor():
		audio.stream = track
		audio.play()
		
func jump():
	super()
	process_jump_audio()
		
func landed():
	if not audio:
		return
	var track = audio_landing
	audio.stream = track
	audio.play()
	
func process_jump_audio():
	if not audio:
		return
	var track = audio_jump
	audio.stream = track
	audio.play()
