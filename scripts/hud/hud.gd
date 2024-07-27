class_name Hud

extends CanvasLayer

# Properties
@export var player : Player

# On Ready
@onready var player_bar = $MainContainer/TopContainer/PlayerBar

func _ready():
	setup_player_bar()
	
func setup_player_bar():
	if not player:
		printerr("hud cannot setup health bar, no selected player")
		return
	if not player_bar:
		printerr("hud cannot setup player bar")
		return
	player_bar.setup_player(player)
