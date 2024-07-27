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

func _ready():
	setup_player_bar()
	setup_interact_text()
	setup_attack_controls()
	setup_level_name()
	
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
