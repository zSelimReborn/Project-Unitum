class_name Hud

extends CanvasLayer

# Properties
@export var player : Player

# On Ready
@onready var player_bar = $MainContainer/TopContainer/PlayerBar
@onready var interact_text = $MainContainer/ControlsContainer/InteractText

func _ready():
	setup_player_bar()
	setup_interact_text()
	
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
