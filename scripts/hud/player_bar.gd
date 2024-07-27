class_name PlayerBar

extends Control

# Properties
@export var character_texture : Texture2D
@export var shadow_texture : Texture2D

# On Ready
@onready var texture_thumb = $PlayerThumb
@onready var health_bar = $HealthBar
@onready var textures = {
	Types.PlayerState.Shadow: shadow_texture,
	Types.PlayerState.Character: character_texture
}

#Variables
var selected_player : Player

func setup_player(player: Player):
	selected_player = player
	if not selected_player:
		printerr("unable to setup player health bar")
		return
	selected_player.on_change_state.connect(change_player_thumb)
	change_player_thumb(Types.PlayerState.Shadow, selected_player.state)
	if not health_bar:
		printerr("hud cannot setup health bar, no bar")
		return
	health_bar.setup_player(player)

func change_player_thumb(old_state, current_state):
	if not texture_thumb:
		printerr("unable to change player thumb, no texture")
		return
	var texture = textures[current_state]
	texture_thumb.texture = texture
