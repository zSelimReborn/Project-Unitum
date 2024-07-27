class_name AttackControls

extends Control

# Properties
@export var fire_active: Texture2D
@export var fire_inactive: Texture2D
@export var water_active: Texture2D
@export var water_inactive: Texture2D
@export var earth_active: Texture2D
@export var earth_inactive: Texture2D
@export var air_active: Texture2D
@export var air_inactive: Texture2D

#On Ready
@onready var fire_texture = $MainContainer/FireContainer/AttackBackground/AttackTexture
@onready var water_texture = $MainContainer/WaterContainer/AttackBackground/AttackTexture
@onready var earth_texture = $MainContainer/EarthContainer/AttackBackground/AttackTexture
@onready var air_texture = $MainContainer/AirContainer/AttackBackground/AttackTexture

@onready var textures_objects = {
	Types.Elements.FIRE: fire_texture,
	Types.Elements.WATER: water_texture,
	Types.Elements.EARTH: earth_texture,
	Types.Elements.AIR: air_texture,
}
@onready var textures = {
	Types.Elements.FIRE: {"active": fire_active, "inactive": fire_inactive},
	Types.Elements.WATER: {"active": water_active, "inactive": water_inactive},
	Types.Elements.EARTH: {"active": earth_active, "inactive": earth_inactive},
	Types.Elements.AIR: {"active": air_active, "inactive": air_inactive},
}

func setup_player(player: Player):
	if not player:
		printerr("unable to set attack controls, no player")
		return
	player.on_change_element.connect(on_change_element)
	on_change_element(Types.Elements.WATER, player.current_element)
	
func reset_all():
	for element in textures_objects:
		textures_objects[element].texture = textures[element]["inactive"]
	
func on_change_element(old_element, current_element):
	reset_all()
	var texture = textures_objects[current_element]
	var active_texture = textures[current_element]["active"]
	if not texture or not active_texture:
		printerr("unable to set attack control active, no texture or color")
		return
	texture.texture = active_texture
