class_name Relic

extends BaseInteractable

@export var relic_type : Types.PlayerState
@export var ui_texture : Texture2D
@export var ui_text : String

func _ready():
	super()
	instant_interact = true

func interact(player: Player):
	if not player:
		return false
	var relic_component = player.get_node("RelicComponent")
	if not relic_component:
		return false
	return relic_component.add_relic(self)
