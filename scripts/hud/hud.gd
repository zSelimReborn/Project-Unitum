class_name Hud

extends CanvasLayer

# Properties
@export var player : Player
@export var level_name : String

# On Ready
@onready var player_bar = $MainContainer/TopContainer/PlayerBar
@onready var interact_text = $MainContainer/ControlsContainer/InteractText
@onready var attack_controls = $MainContainer/AttackControlsContainer/AttackControls
@onready var level_name_object = $MainContainer/LevelContainer/LevelName
@onready var pause_menu = $PopupContainer/PopupBackground/PauseMenu
@onready var popup_container = $PopupContainer

func _ready():
	setup_player_bar()
	setup_interact_text()
	setup_attack_controls()
	setup_level_name()
	setup_pause_menu()
	
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
	
func on_pause_menu_requested():
	if not pause_menu or not player:
		printerr("unable to load pause menu, no menu or player")
		return
	
	toggle_pause_menu(player.in_game)
	
func toggle_popup(show: bool):
	if not popup_container:
		printerr("unable to toggle popup, no popup container: ", show)
		return
	if show:
		popup_container.show()
	else:
		popup_container.hide()
		
func toggle_pause_menu(show: bool):
	if not pause_menu:
		printerr("unable to toggle pause menu, no menu")
		return
	if show:
		pause_menu.show()
	else:
		pause_menu.hide()
	toggle_popup(show)
	
func on_continue_pressed():
	if not player:
		printerr("unable to continue pause menu, no player")
		return
	player.switch_pause_menu()
	
func on_exit_pressed():
	get_tree().quit()
