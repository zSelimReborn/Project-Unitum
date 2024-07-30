class_name RelicPopup

extends Control

#On Ready
@onready var relic_texture = $Panel/VBoxContainer/RelicTexture
@onready var relic_type = $Panel/VBoxContainer/HBoxContainer/RelicType
@onready var relic_name = $Panel/VBoxContainer/RelicName
@onready var relic_description = $Panel/VBoxContainer/Description
@onready var audio = $Audio

# Properties
@export var base_description = "New relic found. You gained %1 boost in %2"

var boost = {
	Types.PlayerState.Character: {"value": "20%", "label": "Attack"},
	Types.PlayerState.Shadow: {"value": "10%", "label": "Defense"}
}

signal on_popup_close()

var type_strings = {
	Types.PlayerState.Character: "Anti-Matter",
	Types.PlayerState.Shadow: "Anti-Shadow"
}

func _on_close_button_pressed():
	play_button_sound()
	on_popup_close.emit()

func setup_values(type, data):
	if not data:
		printerr("unable to setup relic values, no stuff")
		return
	if not relic_texture:
		printerr("unable to show relic texture, no object")
		return
	if not relic_type:
		printerr("unable to show relic type, no type")
		return
	if not relic_name: 
		printerr("unable to show relic name, no name")
		return
	if not relic_description:
		printerr("unable to show relic description, no description")
		return
	
	var texture = data["texture"]
	var name = data["name"]
	var type_string = type_strings[type]
	relic_texture.texture = texture
	relic_name.text = name
	relic_type.text = type_string
	relic_description.text = build_description(type)
	
func build_description(type: Types.PlayerState):
	var description = base_description
	var stats = boost[type]
	description = description.replace("%1", stats["value"])
	description = description.replace("%2", stats["label"])
	return description

func play_button_sound():
	if not audio:
		return
	audio.play()
