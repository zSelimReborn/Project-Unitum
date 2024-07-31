class_name Cagliostro

extends BaseInteractable

# Properties
@export var enemy_spawner : EnemySpawner
@export var player : Player
@export var wait_time_after_stage = 2.0
@export var shake_duration : float = 5.0
@export var shadow_class : PackedScene
@export var shadow_spawn_point : Node2D
@export var end_menu_wait : float = 2
@export var end_menu : String

# On Ready
@onready var sprite = $AnimatedSprite2D

@onready var pacifist_initial_dialogue = "res://assets/dialogues/cagliostro_initial_pacifist.txt"
@onready var pacifist_initial_dialogue_tag = "cagliostro_initial_pacifist"

@onready var pacifist_final_dialogue = "res://assets/dialogues/cagliostro_final_pacifist.txt"
@onready var pacifist_final_dialogue_tag = "cagliostro_final_pacifist"

@onready var initial_dialogue = "res://assets/dialogues/cagliostro_initial.txt"
@onready var initial_dialogue_tag = "cagliostro_initial"

@onready var final_dialogue_bad = "res://assets/dialogues/cagliostro_final_bad.txt"
@onready var final_dialogue_good = "res://assets/dialogues/cagliostro_final_good.txt"

@onready var final_dialogue_tag_bad = "cagliostro_final_bad"
@onready var final_dialogue_tag_good = "cagliostro_final_good"

# Variables
var selected_ending = Types.Ending.Human

func _ready():
	super()
	if not player:
		player = get_tree().get_first_node_in_group("player")
	if not enemy_spawner:
		printerr("cagliostro error, enemy spawner missing")
		return
	enemy_spawner.on_stage_completed.connect(on_stage_completed)
	player.camera_shake_ended.connect(handle_endings)
	player.jump_dialogue_requested.connect(on_end_dialogue)
	selected_ending = pick_current_ending()

func on_stage_completed():
	if not wait_time_after_stage:
		wait_time_after_stage = 2.0
	await get_tree().create_timer(wait_time_after_stage).timeout	
	player.apply_camera_shake(shake_duration)

func interact(player: Player):
	if not is_interactable:
		return false
	if not player:
		return false
	if selected_ending == Types.Ending.Pacifist:
		if not start_dialogue(pacifist_initial_dialogue, pacifist_initial_dialogue_tag):
			on_stage_completed()
			is_interactable = false
		return true
	if not enemy_spawner:
		printerr("cagliostro error, enemy spawner missing")
		return false
	
	if not start_dialogue(initial_dialogue, initial_dialogue_tag):
		start_stage()

func start_dialogue(selected_dialogue, dialogue_tag):
	if not player:
		printerr("unable to start dialogue, no player")
		return false
	if not selected_dialogue:
		printerr("unable to start dialogue, no resource")
		return false
	if not player.init_dialogue(selected_dialogue, dialogue_tag):
		printerr("unable to start dialogue, initialization failed")
		return false
	player.start_dialogue()
	return true

func on_end_dialogue(dialogue_tag):
	if dialogue_tag == initial_dialogue_tag:
		start_stage()
	elif dialogue_tag == pacifist_initial_dialogue_tag:
		on_stage_completed()
		is_interactable = false
	elif dialogue_tag == final_dialogue_tag_bad:
		sprite.visible = false		
		go_end_menu()
	elif dialogue_tag == final_dialogue_tag_good:
		go_end_menu()
	elif dialogue_tag == pacifist_final_dialogue_tag:
		go_end_menu()

func start_stage():
	is_interactable = false
	enemy_spawner.start_stage()	
	
func handle_endings():
	match (selected_ending):
		Types.Ending.Pacifist:
			pacifist_ending()
			pass
		Types.Ending.Human:
			human_ending()
			pass
		Types.Ending.Shadow:
			shadow_ending()
			pass
		Types.Ending.Good:
			good_ending()
			pass
		
func pick_current_ending():
	if PlayerStorage.kill_count <= 0:
		return Types.Ending.Pacifist
	var relic_component = player.get_node("RelicComponent") as RelicComponent
	if not relic_component:
		printerr("player has no relic component, going to human ending")
		return Types.Ending.Human
	var human_relic = relic_component.get_relic(Types.PlayerState.Character)
	var shadow_relic = relic_component.get_relic(Types.PlayerState.Shadow)
	if shadow_relic > human_relic:
		return Types.Ending.Shadow
	elif (not relic_component.collected_all_relics()):
		return Types.Ending.Human
	else:
		return Types.Ending.Good
	
func human_ending():
	PlayerStorage.ending = Types.Ending.Human
	if not start_dialogue(final_dialogue_bad, final_dialogue_tag_bad):
		on_end_dialogue(final_dialogue_tag_bad)

func shadow_ending():
	PlayerStorage.ending = Types.Ending.Shadow	
	player.turn_in_shadow()	
	if not start_dialogue(final_dialogue_bad, final_dialogue_tag_bad):
		on_end_dialogue(final_dialogue_tag_bad)
	
func good_ending():
	PlayerStorage.ending = Types.Ending.Good	
	spawn_shadow()
	if not start_dialogue(final_dialogue_good, final_dialogue_tag_good):
		on_end_dialogue(final_dialogue_tag_good)
	
func pacifist_ending():
	PlayerStorage.ending = Types.Ending.Pacifist	
	spawn_shadow()
	if not start_dialogue(pacifist_final_dialogue, pacifist_final_dialogue_tag):
		on_end_dialogue(pacifist_final_dialogue_tag)

func spawn_shadow():
	if not shadow_class:
		printerr("unable to spawn shadow :(, no class")
		return
	if not shadow_spawn_point:
		printerr("unable to spawn shadow :(, no spawn point")
		return
	var shadow = shadow_class.instantiate()
	shadow.transform = shadow_spawn_point.transform
	owner.add_child(shadow)
	
func go_end_menu():
	if not end_menu:
		printerr("unable to go end menu, no class")
		return
	await get_tree().create_timer(end_menu_wait).timeout
	SceneManager.goto_scene(end_menu)
