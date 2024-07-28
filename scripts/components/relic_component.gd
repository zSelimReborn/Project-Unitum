class_name RelicComponent

extends Node

# Properties
@export var max_num_relics : int = 2
@export var relic_attack_multiplier : float = 0.20
@export var relic_defense_multiplier : float = 0.1

# Events
signal new_relic_added(type, amount, relic_data)

# Variables
var last_relic_texture = null
var last_relic_name = null

var relics = {
	Types.PlayerState.Character: 0,
	Types.PlayerState.Shadow: 0
}

func add_relic(relic: Relic):
	if not relic:
		return false
	
	var type = relic.relic_type
	if relics[type] + 1 > max_num_relics:
		printerr("tried to exceed max relics")
		return false
	relics[type] += 1
	last_relic_texture = relic.ui_texture
	last_relic_name = relic.ui_text
	var data = {
		"texture": relic.ui_texture,
		"name": relic.ui_text
	}
	new_relic_added.emit(type, relics[type], data)
	return true
	
func restore_relics():
	relics = PlayerStorage.relics
	
func get_relics():
	return relics
	
func get_relic(type: Types.PlayerState):
	return relics[type]
	
func collected_all_relics():
	var human_relic = get_relic(Types.PlayerState.Character)
	var shadow_relic = get_relic(Types.PlayerState.Shadow)
	return human_relic >= max_num_relics and shadow_relic >= max_num_relics
