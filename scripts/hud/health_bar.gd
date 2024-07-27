class_name HealthBar

extends Control

# Properties
@onready var bar = $Bar

# Variables
var selected_player : Player

func setup_player(player: Player):
	selected_player = player
	if not selected_player:
		printerr("unable to setup player health bar")
		return
	selected_player.on_change_health.connect(on_change_health)
	bar.max_value = selected_player.max_health
	bar.value = selected_player.health

func on_change_health(_old_health, new_health):
	bar.value = new_health
