class_name Hud

extends CanvasLayer

# Properties
@export var player : Player

# On Ready
@onready var player_bar = $MainContainer/TopContainer/PlayerBar
@onready var interact_text = $MainContainer/ControlsContainer/InteractText
@onready var attack_controls = $MainContainer/AttackControlsContainer/AttackControls

func _ready():
	setup_player_bar()
	setup_interact_text()
	setup_attack_controls()
	
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
