class_name RelicPopup

extends Control

#On Ready
@onready var relic_texture = $Panel/VBoxContainer/RelicTexture
@onready var relic_type = $Panel/VBoxContainer/HBoxContainer/RelicType
@onready var relic_name = $Panel/VBoxContainer/RelicName


signal on_popup_close()

var type_strings = {
	Types.PlayerState.Character: "Anti-Matter",
	Types.PlayerState.Shadow: "Anti-Shadow"
}

func _on_close_button_pressed():
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
	
	var texture = data["texture"]
	var name = data["name"]
	var type_string = type_strings[type]
	relic_texture.texture = texture
	relic_name.text = name
	relic_type.text = type_string
