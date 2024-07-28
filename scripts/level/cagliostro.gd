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
@export var end_menu : PackedScene

func _ready():
	super()
	if not player:
		player = get_tree().get_first_node_in_group("player")
	if not enemy_spawner:
		printerr("cagliostro error, enemy spawner missing")
		return
	enemy_spawner.on_stage_completed.connect(on_stage_completed)
	player.camera_shake_ended.connect(handle_endings)

func on_stage_completed():
	await get_tree().create_timer(wait_time_after_stage).timeout	
	player.apply_camera_shake(shake_duration)

func interact(player: Player):
	if not is_interactable:
		return false
	if not player:
		return false
	if PlayerStorage.kill_count <= 0:
		on_stage_completed()
		is_interactable = false
		return true
	if not enemy_spawner:
		printerr("cagliostro error, enemy spawner missing")
		return false
	start_stage()

func start_stage():
	is_interactable = false
	enemy_spawner.start_stage()	
	
func handle_endings():
	if PlayerStorage.kill_count <= 0:
		pacifist_ending()
		return
	var relic_component = player.get_node("RelicComponent") as RelicComponent
	if not relic_component:
		printerr("player has no relic component, going to good ending")
		return
	var human_relic = relic_component.get_relic(Types.PlayerState.Character)
	var shadow_relic = relic_component.get_relic(Types.PlayerState.Shadow)
	if shadow_relic > human_relic:
		shadow_ending()
	elif (not relic_component.collected_all_relics()):
		human_ending()
	else:
		good_ending()
	
func human_ending():
	print("human ending")
	PlayerStorage.ending = Types.Ending.Human
	go_end_menu()
	# Nothing fancy
	# TODO Game over
	# TODO Cagliostro speak

func shadow_ending():
	print("shadow ending")
	PlayerStorage.ending = Types.Ending.Shadow	
	# TODO switch to shadow
	# TODO Game over
	player.turn_in_shadow()
	go_end_menu()	
	
func good_ending():
	print("good ending")
	PlayerStorage.ending = Types.Ending.Good	
	spawn_shadow()
	go_end_menu()	
	# TODO Cagliostro speak
	
func pacifist_ending():
	print("pacifist ending")
	PlayerStorage.ending = Types.Ending.Pacifist	
	spawn_shadow()
	go_end_menu()	

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
	SceneManager.goto_scene(end_menu.resource_path)
