class_name Hud

extends CanvasLayer

# Properties
@export var player : Player
@export var level_name : String
@export var initial_level : String
@export var open_menu_sound : AudioStream
@export var close_menu_sound : AudioStream

# On Ready
@onready var player_bar = $MainContainer/TopContainer/PlayerBar
@onready var attack_controls = $MainContainer/AttackControlsContainer/AttackControls
@onready var level_name_object = $MainContainer/LevelContainer/LevelName
@onready var pause_menu = $PopupContainer/PopupBackground/PauseMenu
@onready var popup_container = $PopupContainer
@onready var relic_popup = $PopupContainer/PopupBackground/RelicPopup
@onready var death_menu = $PopupContainer/PopupBackground/DeathMenu
@onready var interact_text = $MainContainer/BottomGrid/InteractPanel/InteractText
@onready var dialogue_box = $MainContainer/BottomGrid/DialoguePanel/DialogueBox

@onready var audio = $Audio

# Variables
var initial_level_path = null

func _ready():
	setup_initial_level_path()
	setup_player_bar()
	setup_interact_text()
	setup_attack_controls()
	setup_level_name()
	setup_pause_menu()
	setup_death_menu()
	setup_relic_popup()
	setup_interaction_hint()
	setup_dialogue_flow()
	
func setup_initial_level_path():
	if not initial_level:
		printerr("hud, initial level empty, fall back to main menu")
		initial_level_path = "res://scenes/main_menu_level.tscn"
	else:
		initial_level_path = initial_level
	
func setup_level_name():
	if not level_name_object:
		return
	level_name_object.set_level_name(level_name)
	
func setup_player_bar():
	if not player:
		printerr("hud cannot setup health bar, no selected player")
		return
	if not player_bar:
		printerr("hud cannot setup player bar")
		return
	player_bar.setup_player(player)

func setup_interact_text():
	if not player:
		printerr("hud cannot setup interact text, no selected player")
		return
	if not interact_text:
		printerr("hud cannot setup interact text")
		return
	interact_text.setup_player(player)
	
func setup_attack_controls():
	if not player:
		printerr("hud cannot setup attack controls, no selected player")
		return
	if not attack_controls:
		printerr("hud cannot setup attack_controls")
		return
	attack_controls.setup_player(player)
	
func setup_pause_menu():
	if not player:
		printerr("hud cannot setup pause menu, no selected player")
		return
	if not pause_menu:
		printerr("hud cannot setup pause menu")
		return
	player.on_pause_menu_requested.connect(on_pause_menu_requested)
	pause_menu.setup_player(player)
	pause_menu.continue_pressed.connect(on_continue_pressed)
	pause_menu.exit_pressed.connect(on_exit_pressed)
	
func setup_death_menu():
	if not player:
		printerr("hud cannot setup death menu, no selected player")
		return
	if not death_menu:
		printerr("hud cannot setup death menu")
		return
	player.on_death_menu_requested.connect(on_death_menu_requested)
	death_menu.restart_pressed.connect(on_death_restart_pressed)
	death_menu.back_pressed.connect(on_death_back_pressed)
	death_menu.exit_pressed.connect(on_exit_pressed)
	
func on_death_menu_requested():
	game_over()
	
func on_death_restart_pressed():
	PlayerStorage.reset()
	SceneManager.goto_scene(initial_level_path)
	
func on_death_back_pressed():
	SceneManager.goto_scene(get_tree().current_scene.scene_file_path)
	
func setup_relic_popup():
	if not player:
		printerr("hud cannot setup relic popup, no selected player")
		return
	if not relic_popup:
		printerr("hud canno setup relic popup")
		return
	player.on_relic_found.connect(on_relic_found)
	relic_popup.on_popup_close.connect(on_relic_close)
	
func setup_interaction_hint():
	if not player:
		printerr("hud cannot setup interaction hint, no selected player")
		return
	if not dialogue_box:
		printerr("hud cannot setup interaction hint, no dialogue box")
		return
	player.on_interaction_hint_requested.connect(interaction_hint_requested)
	
func setup_dialogue_flow():
	if not player:
		printerr("hud cannot setup dialogue flow, no selected player")
		return
	if not dialogue_box:
		printerr("hud cannot setup dialogue flow, no dialogue box")
		return
	player.jump_dialogue_requested.connect(on_jump_dialogue)
	player.next_dialogue_requested.connect(on_next_dialogue)
	
func interaction_hint_requested(interactable: BaseInteractable):
	if not interactable:
		printerr("hud cannot set interaction hint, interactable empty")
		return
	if not interactable.interaction_hint:
		return
	dialogue_box.show()
	dialogue_box.set_dialogue(interactable.interaction_hint)
	player.switch_dialogue()
	
func on_jump_dialogue(tag):
	if not dialogue_box:
		return
	dialogue_box.set_dialogue("")
	dialogue_box.hide()
	player.switch_dialogue()
	
func on_next_dialogue(line: String):
	dialogue_box.set_dialogue(line)	
	dialogue_box.show()
	if not player.in_dialogue:
		player.switch_dialogue()
	
func on_pause_menu_requested():
	if not pause_menu or not player:
		printerr("unable to load pause menu, no menu or player")
		return
	
	toggle_relic_popup(false)	
	toggle_pause_menu(player.in_game)
	
func toggle_popup(show: bool):
	if not popup_container:
		printerr("unable to toggle popup, no popup container: ", show)
		return
	if show:
		popup_container.show()
	else:
		popup_container.hide()

func play_menu_audio(open: bool):
	if not audio:
		return
	var track = open_menu_sound if open else close_menu_sound
	if audio.is_playing():
		return
	audio.stream = track
	audio.play()

func toggle_pause_menu(show: bool):
	if not pause_menu:
		printerr("unable to toggle pause menu, no menu")
		return
	if show:
		pause_menu.show()
	else:
		pause_menu.hide()
	toggle_popup(show)
	play_menu_audio(show)	
	
func game_over():
	if not death_menu:
		printerr("unable to toggle death menu, no menu")
		return
	toggle_popup(true)	
	relic_popup.hide()
	pause_menu.hide()
	death_menu.show()
	death_menu.grab_click_focus()
	
func on_continue_pressed():
	if not player:
		printerr("unable to continue pause menu, no player")
		return
	player.switch_pause_menu()
	
func on_exit_pressed():
	get_tree().quit()
	
func on_relic_found(type, data):
	if not relic_popup:
		printerr("hud unable to show new relic popup")
		return
	relic_popup.setup_values(type, data)
	toggle_relic_popup(player.in_game)
	
func toggle_relic_popup(show: bool):
	if show:
		relic_popup.show()
	else:
		relic_popup.hide()
	toggle_popup(show)
	
func on_relic_close():
	if not player:
		printerr("unable to close relic popup, no player")
		return
	player.switch_relic_menu(null, null)
